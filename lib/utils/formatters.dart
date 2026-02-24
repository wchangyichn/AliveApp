String formatDateRange(DateTime start, DateTime end) {
  String twoDigit(int value) => value.toString().padLeft(2, '0');
  final String s = '${start.year}-${twoDigit(start.month)}-${twoDigit(start.day)}';
  final String e = '${end.year}-${twoDigit(end.month)}-${twoDigit(end.day)}';
  return s == e ? s : '$s 至 $e';
}

String monthBucket(DateTime date) {
  return '${date.year}年${date.month}月';
}
