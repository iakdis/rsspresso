import 'package:intl/intl.dart';

String parseTimeDifference(DateTime dateTime, {bool dense = false}) {
  final date = dateTime;
  final now = DateTime.now();

  final secondDifference = now.difference(date).inSeconds;
  if (secondDifference < 60) {
    return dense
        ? '${secondDifference}s'
        : '$secondDifference second${secondDifference > 1 ? 's' : ''} ago';
  } else {
    // More than 59 seconds ago
    final minuteDifference = now.difference(date).inMinutes;
    if (minuteDifference < 60) {
      return dense
          ? '${minuteDifference}m'
          : '$minuteDifference minute${minuteDifference > 1 ? 's' : ''} ago';
    } else {
      // More than 59 minutes ago
      final hourDifference = now.difference(date).inHours;
      if (hourDifference < 24) {
        return dense
            ? '${hourDifference}h'
            : '$hourDifference hour${hourDifference > 1 ? 's' : ''} ago';
      } else {
        // More than 23 hours ago
        final dayDifference = now.difference(date).inDays;
        if (dayDifference < 31) {
          return dense
              ? '${dayDifference}d'
              : '$dayDifference day${dayDifference > 1 ? 's' : ''} ago';
        } else {
          // More than 30 days ago
          final monthDifference = (dayDifference / 31).round();
          if (monthDifference < 12) {
            return dense
                ? '${monthDifference}mo'
                : '$monthDifference month${monthDifference > 1 ? 's' : ''} ago';
          } else {
            // More than 11 months ago
            final yearDifference = (monthDifference / 12).round();
            return dense
                ? '${yearDifference}y'
                : '$yearDifference year${yearDifference > 1 ? 's' : ''} ago';
          }
        }
      }
    }
  }
}

String parseDate(DateTime date) {
  final formatter = DateFormat('dd.MM.yyyy, hh:mm:ss a');
  return formatter.format(date);
}
