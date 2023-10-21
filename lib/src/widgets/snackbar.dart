import 'package:flutter/material.dart';

void showSnackbar({
  required String text,
  required int seconds,
  required BuildContext context,
  void Function()? undoAction,
  bool clearSnackbars = true,
}) {
  if (clearSnackbars) ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    clipBehavior: Clip.antiAlias,
    backgroundColor: const Color(0xFF2C2C2C),
    content: SelectableText(text, style: const TextStyle(color: Colors.white)),
    duration: Duration(seconds: seconds),
    action: undoAction != null
        ? SnackBarAction(
            label: 'Undo',
            onPressed: undoAction,
            textColor: Colors.white,
          )
        : SnackBarAction(
            label: 'Dismiss',
            onPressed: () {},
            textColor: Colors.white,
          ),
  ));
}
