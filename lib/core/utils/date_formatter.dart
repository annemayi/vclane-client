extension DateTimeFormatting on DateTime {
  String timeAgo() {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${month}/${day}/${year}';
  }

  String toIso() => toIso8601String();
}

String formatTimestamp(dynamic timestamp) {
  if (timestamp == null) return '--';
  if (timestamp is DateTime) return timestamp.timeAgo();
  return timestamp.toString();
}
