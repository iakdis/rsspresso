import 'package:flutter/material.dart';

import '../themes/theme.dart';
import '../utils/date.dart';

class DateDifference extends StatelessWidget {
  const DateDifference({
    super.key,
    required this.date,
    required this.hasRead,
    this.dense = false,
  });

  final DateTime date;
  final bool hasRead;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!hasRead) ...[
          Icon(
            Icons.circle,
            size: 8.0,
            color: markedDotColor(brightness: Theme.of(context).brightness),
          ),
          const SizedBox(width: 4.0),
        ],
        Text(
          parseTimeDifference(date, dense: dense),
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}
