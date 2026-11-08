import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/setting_keys.dart';
import '../../../core/domain/enums.dart';
import '../domain/companion_models.dart';
import '../domain/pairing_crypto.dart';
import 'companion_secrets.dart';

const claudeCodeApplication = 'claude-code';
const vscodeApplication = 'vscode';

class CompanionRepository {
  CompanionRepository({
    required AppDatabase database,
    required this._secrets,
    this._clock = DateTime.now,
  }) : _db = database;

  final AppDatabase _db;
  final CompanionSecrets _secrets;
  final DateTime Function() _clock;

  Stream<List<PairedDevice>> watchDevices() => (_db.select(
    _db.pairedDevices,
  )..orderBy([(t) => OrderingTerm.asc(t.pairedAt)])).watch();

  Future<bool> hasDevices() async =>
      (await _db.select(_db.pairedDevices).get()).isNotEmpty;

  Future<String?> secretFor(String deviceId) => _secrets.read(deviceId);

  Future<String> addDevice(String name, String secret) async {
    final source = await _ensureSource();
    final device = await _db
        .into(_db.pairedDevices)
        .insertReturning(
          PairedDevicesCompanion.insert(
            sourceId: source.id,
            kind: DeviceKind.desktopCompanion,
            name: name,
            // Only a fingerprint: the signing key stays in secure storage.
            publicKey: secretFingerprint(secret),
            pairedAt: _clock(),
          ),
        );
    await _secrets.save(device.id, secret);
    return device.id;
  }

  /// Saves segments from a paired computer. A segment that already exists is
  /// extended, which is what makes a running session update live.
  Future<void> ingest(String deviceId, List<ClaudeSegment> segments) async {
    final now = _clock();
    await (_db.update(_db.pairedDevices)..where((t) => t.id.equals(deviceId)))
        .write(PairedDevicesCompanion(lastSeenAt: Value(now)));

    // Accepted, then dropped, so the computer doesn't keep retrying them.
    if (await _db.readSetting(privateSessionSettingKey) == 'true') return;

    final source = await _ensureSource();
    final floor =
        int.tryParse(await _db.readSetting(importFloorSettingKey) ?? '') ?? 0;
    final tombstones =
        (await (_db.select(
              _db.eventTombstones,
            )..where((t) => t.sourceId.equals(source.id))).get())
            .map((r) => r.externalId)
            .toSet();

    await _db.transaction(() async {
      for (final segment in segments) {
        final externalId = _externalId(deviceId, segment.id);
        if (segment.startMs < floor || tombstones.contains(externalId)) {
          continue;
        }
        final isVsCode = segment.source == SegmentSource.vscode;
        final end = DateTime.fromMillisecondsSinceEpoch(segment.endMs);
        await _db
            .into(_db.activityEvents)
            .insert(
              ActivityEventsCompanion.insert(
                sourceId: source.id,
                externalId: Value(externalId),
                kind: isVsCode
                    ? ActivityKind.codingSession
                    : ActivityKind.aiSession,
                category: isVsCode
                    ? ActivityCategory.coding
                    : ActivityCategory.ai,
                title:
                    '${isVsCode ? 'VS Code' : 'Claude Code'} · ${segment.project}',
                application: Value(
                  isVsCode ? vscodeApplication : claudeCodeApplication,
                ),
                domain: Value(segment.repository),
                startedAt: DateTime.fromMillisecondsSinceEpoch(segment.startMs),
                endedAt: Value(end),
              ),
              onConflict: DoUpdate(
                (_) => ActivityEventsCompanion(endedAt: Value(end)),
                target: [
                  _db.activityEvents.sourceId,
                  _db.activityEvents.externalId,
                ],
                where: (old) =>
                    old.isCorrected.equals(false) &
                    old.endedAt.isSmallerThanValue(end),
              ),
            );
      }
    });
  }

  /// Removes a computer. With [keepEvents] false, its sessions go too.
  Future<void> unpair(String deviceId, {required bool keepEvents}) async {
    await _secrets.delete(deviceId);
    await _db.transaction(() async {
      await (_db.delete(
        _db.pairedDevices,
      )..where((t) => t.id.equals(deviceId))).go();
      if (!keepEvents) {
        await (_db.delete(
              _db.activityEvents,
            )..where((t) => t.externalId.like('${_externalId(deviceId, '')}%')))
            .go();
      }
    });
  }

  String _externalId(String deviceId, String segmentId) =>
      'claude:$deviceId:$segmentId';

  Future<DataSource> _ensureSource() async {
    final existing =
        await (_db.select(_db.dataSources)
              ..where((t) => t.kind.equalsValue(SourceKind.desktopCompanion))
              ..limit(1))
            .getSingleOrNull();
    return existing ??
        _db
            .into(_db.dataSources)
            .insertReturning(
              DataSourcesCompanion.insert(
                kind: SourceKind.desktopCompanion,
                status: SourceStatus.connected,
                connectedAt: _clock(),
              ),
            );
  }
}
