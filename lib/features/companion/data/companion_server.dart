import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../domain/companion_models.dart';
import '../domain/pairing_crypto.dart';
import 'companion_repository.dart';

const companionPort = 47831;

const _maxBodyBytes = 256 * 1024;
const _maxSegments = 200;
const _pairingLifetime = Duration(minutes: 5);
const _maxPairingAttempts = 5;
const _maxClockSkew = Duration(minutes: 10);

class _Pairing {
  _Pairing(this.code, this.expiresAt);

  final String code;
  final DateTime expiresAt;
  String? name;
  PairingExchange? exchange;
  int attempts = 0;
}

class _BadRequest implements Exception {
  const _BadRequest([this.status = HttpStatus.badRequest]);

  final int status;
}

/// Receives events from paired computers on the local network. It runs only
/// while the app is open and pairing or paired, and answers nothing else.
class CompanionServer {
  CompanionServer(
    this._repository, {
    this.onPaired,
    this.onLive,
    this._clock = DateTime.now,
    Random? random,
  }) : _random = random ?? Random.secure();

  final CompanionRepository _repository;
  final void Function()? onPaired;

  /// Reports sessions in progress and sessions that just finished.
  final void Function(Set<String> working, Set<String> finished)? onLive;
  final DateTime Function() _clock;
  final Random _random;

  HttpServer? _server;
  _Pairing? _pairing;

  bool get isRunning => _server != null;
  int? get port => _server?.port;

  Future<void> start({int port = companionPort}) async {
    if (_server != null) return;
    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    _server = server;
    server.listen(_handle, onError: (Object _) {});
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    await server?.close(force: true);
  }

  /// Starts accepting one new computer, and returns the code to show.
  ({String code, DateTime expiresAt}) beginPairing() {
    final code = _random.nextInt(1000000).toString().padLeft(6, '0');
    final expiresAt = _clock().add(_pairingLifetime);
    _pairing = _Pairing(code, expiresAt);
    return (code: code, expiresAt: expiresAt);
  }

  void cancelPairing() => _pairing = null;

  Future<void> _handle(HttpRequest request) async {
    var status = HttpStatus.ok;
    Object? reply;
    try {
      if (request.method != 'POST') throw const _BadRequest(405);
      final body = await _readBody(request);
      reply = switch (request.uri.path) {
        '/v1/pair/start' => _pairStart(_json(body)),
        '/v1/pair/finish' => await _pairFinish(_json(body)),
        '/v1/events' => await _events(request.headers, body),
        _ => throw const _BadRequest(HttpStatus.notFound),
      };
    } on _BadRequest catch (error) {
      status = error.status;
    } on Exception {
      // Details are never returned or logged: requests carry key material.
      status = HttpStatus.internalServerError;
    }
    final response = request.response..statusCode = status;
    response.headers.contentType = ContentType.json;
    response.write(jsonEncode(reply ?? {'ok': status == HttpStatus.ok}));
    await response.close();
  }

  Future<String> _readBody(HttpRequest request) async {
    final bytes = <int>[];
    await for (final chunk in request) {
      bytes.addAll(chunk);
      if (bytes.length > _maxBodyBytes) {
        throw const _BadRequest(HttpStatus.requestEntityTooLarge);
      }
    }
    try {
      return utf8.decode(bytes);
    } on FormatException {
      throw const _BadRequest();
    }
  }

  Map<String, Object?> _json(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, Object?>) return decoded;
    } on FormatException {
      // Falls through to the rejection below.
    }
    throw const _BadRequest();
  }

  _Pairing _activePairing() {
    final pairing = _pairing;
    if (pairing == null || _clock().isAfter(pairing.expiresAt)) {
      throw const _BadRequest(HttpStatus.forbidden);
    }
    return pairing;
  }

  Map<String, Object?> _pairStart(Map<String, Object?> body) {
    final pairing = _activePairing();
    final name = body['name'];
    final clientPublic = body['client_public'];
    if (name is! String ||
        name.isEmpty ||
        name.length > 60 ||
        clientPublic is! String) {
      throw const _BadRequest();
    }
    final exchange = PairingExchange.accept(clientPublic);
    if (exchange == null) throw const _BadRequest();
    pairing
      ..name = name
      ..exchange = exchange;
    return {'server_public': exchange.serverPublic};
  }

  Future<Map<String, Object?>> _pairFinish(Map<String, Object?> body) async {
    final pairing = _activePairing();
    final exchange = pairing.exchange;
    final mac = body['mac'];
    if (exchange == null || mac is! String) throw const _BadRequest();
    if (!exchange.verifyClient(mac, pairing.code)) {
      if (++pairing.attempts >= _maxPairingAttempts) _pairing = null;
      throw const _BadRequest(HttpStatus.forbidden);
    }
    final deviceId = await _repository.addDevice(
      pairing.name!,
      exchange.deriveSecret(pairing.code),
    );
    _pairing = null;
    onPaired?.call();
    return {'device_id': deviceId, 'mac': exchange.serverProof(pairing.code)};
  }

  Future<Map<String, Object?>> _events(HttpHeaders headers, String body) async {
    final deviceId = headers.value('x-workpulse-device');
    final timestamp = headers.value('x-workpulse-timestamp');
    final signature = headers.value('x-workpulse-signature');
    if (deviceId == null || timestamp == null || signature == null) {
      throw const _BadRequest(HttpStatus.unauthorized);
    }
    final secret = await _repository.secretFor(deviceId);
    if (secret == null ||
        !constantTimeEquals(signature, signEvents(secret, timestamp, body))) {
      throw const _BadRequest(HttpStatus.unauthorized);
    }
    final sentMs = int.tryParse(timestamp);
    final now = _clock();
    if (sentMs == null ||
        (now.millisecondsSinceEpoch - sentMs).abs() >
            _maxClockSkew.inMilliseconds) {
      throw const _BadRequest(HttpStatus.unauthorized);
    }

    final raw = _json(body)['segments'];
    if (raw is! List<Object?> || raw.length > _maxSegments) {
      throw const _BadRequest();
    }
    final segments = raw
        .map((item) => ClaudeSegment.parse(item, now: now))
        .nonNulls
        .toList();
    final live = await _repository.ingest(deviceId, segments);
    onLive?.call(live.working, live.finished);
    return {'accepted': segments.length};
  }
}

/// The phone's address on the local network, if it has one.
Future<String?> localNetworkAddress() async {
  final interfaces = await NetworkInterface.list(
    type: InternetAddressType.IPv4,
  );
  bool isPrivate(String ip) =>
      ip.startsWith('192.168.') ||
      ip.startsWith('10.') ||
      RegExp(r'^172\.(1[6-9]|2\d|3[01])\.').hasMatch(ip);
  int rank(NetworkInterface i) =>
      i.name.startsWith('wlan') || i.name.startsWith('ap') ? 0 : 1;

  final ordered = [...interfaces]..sort((a, b) => rank(a).compareTo(rank(b)));
  for (final interface in ordered) {
    for (final address in interface.addresses) {
      if (isPrivate(address.address)) return address.address;
    }
  }
  return null;
}
