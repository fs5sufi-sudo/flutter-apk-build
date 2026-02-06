String timeAgo(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()} سال پیش';
  } else if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()} ماه پیش';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} روز پیش';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} ساعت پیش';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} دقیقه پیش';
  } else {
    return 'لحظاتی پیش';
  }
}
