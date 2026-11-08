/// One stretch of Claude Code work, as reported by the computer.
class ClaudeSegment {
  const ClaudeSegment({
    required this.id,
    required this.project,
    required this.startMs,
    required this.endMs,
    this.repository,
  });

  final String id;
  final String project;
  final int startMs;
  final int endMs;
  final String? repository;

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
