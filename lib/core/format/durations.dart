/// Formats as `5h 42m`, `1h 05m` or `40m`. Null (point events) gives a dash.
/// Formats a running timer as `8m 13s` or `1h 05m 02s`.
String formatElapsed(Duration elapsed) {
  String two(int n) => n.toString().padLeft(2, '0');
  final seconds = elapsed.inSeconds.remainder(60);
  final minutes = elapsed.inMinutes.remainder(60);
  if (elapsed.inHours > 0) {
    return '${elapsed.inHours}h ${two(minutes)}m ${two(seconds)}s';
  }
  return minutes > 0 ? '${minutes}m ${two(seconds)}s' : '${seconds}s';
}

String formatDuration(Duration? duration) {
  if (duration == null) return '—';
  if (duration > Duration.zero && duration < const Duration(minutes: 1)) {
    return '<1m';
  }
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours == 0) return '${minutes}m';
  return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
}
