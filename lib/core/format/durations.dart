/// Formats as `5h 42m`, `1h 05m` or `40m`. Null (point events) gives a dash.
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
