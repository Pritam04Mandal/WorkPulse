enum SegmentSource { claudeCode, vscode }

/// One stretch of work, as reported by a paired computer.
class ClaudeSegment {
  const ClaudeSegment({
    required this.id,
    required this.project,
    required this.startMs,
    required this.endMs,
    this.repository,
    this.source = SegmentSource.claudeCode,
    this.prompts = 0,
    this.working = false,
  });

  final String id;
  final String project;
  final int startMs;
  final int endMs;
  final String? repository;
  final SegmentSource source;
  final int prompts;

  /// The computer says work is happening right now.
  final bool working;

  static final _idPattern = RegExp(r'^[A-Za-z0-9_.:-]{1,120}$');
  static const _longest = Duration(hours: 24);

  /// Returns null for anything malformed. This data comes off the network.
  static ClaudeSegment? parse(Object? raw, {required DateTime now}) {
    if (raw case {
      'id': final String id,
      'project': final String project,
      'start': final int start,
      'end': final int end,
    }) {
      final repository = raw['repo'];
      final source = switch (raw['kind']) {
        null || 'claude_code' => SegmentSource.claudeCode,
        'vscode' => SegmentSource.vscode,
        _ => null,
      };
      if (source == null) return null;
      if (!_idPattern.hasMatch(id) ||
          project.isEmpty ||
          project.length > 100 ||
          (repository != null &&
              (repository is! String || repository.length > 140)) ||
          end < start ||
          end - start > _longest.inMilliseconds ||
          end > now.add(const Duration(minutes: 10)).millisecondsSinceEpoch) {
        return null;
      }
      return ClaudeSegment(
        id: id,
        project: project,
        startMs: start,
        endMs: end,
        repository: repository as String?,
        source: source,
        prompts: switch (raw['prompts']) {
          final int n when n >= 0 && n < 1000000 => n,
          _ => 0,
        },
        working: raw['working'] == true,
      );
    }
    return null;
  }
}

class PairingOffer {
  const PairingOffer({
    required this.code,
    required this.expiresAt,
    this.address,
  });

  final String code;
  final DateTime expiresAt;

  /// `ip:port` on the current network, or null when not on one.
  final String? address;
}
