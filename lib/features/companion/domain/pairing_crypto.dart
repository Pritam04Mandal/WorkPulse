import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

// RFC 3526 group 14. The companion script uses Python's standard library only,
// which has big integers but no elliptic curves.
final _prime = BigInt.parse(
  'FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74'
  '020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F1437'
  '4FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7ED'
  'EE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3DC2007CB8A163BF05'
  '98DA48361C55D39A69163FA8FD24CF5F83655D23DCA3AD961C62F356208552BB'
  '9ED529077096966D670C354E4ABC9804F1746C08CA18217C32905E462E36CE3B'
  'E39E772C180E86039B2783A2EC07A28FB5C55DF06F4C52C9DE2BCBF695581718'
  '3995497CEA956AE515D2261898FA051015728E5A8AACAA68FFFFFFFFFFFFFFFF',
  radix: 16,
);

String hmacHex(List<int> key, String message) =>
    Hmac(sha256, key).convert(utf8.encode(message)).toString();

bool constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var difference = 0;
  for (var i = 0; i < a.length; i++) {
    difference |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return difference == 0;
}

/// Agrees a key with a computer, bound to the code shown on the phone.
class PairingExchange {
  PairingExchange._(this.clientPublic, this.serverPublic, this._key);

  /// Returns null if [clientPublicHex] isn't a usable public value.
  static PairingExchange? accept(String clientPublicHex, [Random? random]) {
    final client = BigInt.tryParse(clientPublicHex, radix: 16);
    if (client == null ||
        client <= BigInt.one ||
        client >= _prime - BigInt.one) {
      return null;
    }
    final source = random ?? Random.secure();
    var private = BigInt.zero;
    for (var i = 0; i < 40; i++) {
      private = (private << 8) | BigInt.from(source.nextInt(256));
    }
    final server = BigInt.two.modPow(private, _prime);
    final shared = client.modPow(private, _prime);
    return PairingExchange._(
      client.toRadixString(16),
      server.toRadixString(16),
      sha256.convert(utf8.encode(shared.toRadixString(16))).bytes,
    );
  }

  final String clientPublic;
  final String serverPublic;
  final List<int> _key;

  String _proof(String role, String code) =>
      hmacHex(_key, '$role|$code|$clientPublic|$serverPublic');

  bool verifyClient(String mac, String code) =>
      constantTimeEquals(mac, _proof('client', code));

  String serverProof(String code) => _proof('server', code);

  /// The key both sides sign events with. It never crosses the network.
  String deriveSecret(String code) => hmacHex(_key, 'secret|$code');
}

String signEvents(String secret, String timestamp, String body) =>
    hmacHex(utf8.encode(secret), '$timestamp.$body');

String secretFingerprint(String secret) =>
    sha256.convert(utf8.encode(secret)).toString().substring(0, 16);
