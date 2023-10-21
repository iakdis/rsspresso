import 'package:flutter/material.dart';

ThemeData theme(
    {required BuildContext context, required Brightness brightness}) {
  final colorScheme = ColorScheme.fromSeed(
    brightness: brightness,
    seedColor: Colors.brown,
  );
  const buttonPadding = EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    tooltipTheme: Theme.of(context)
        .tooltipTheme
        .copyWith(waitDuration: const Duration(milliseconds: 600)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: buttonPadding,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: OutlinedButton.styleFrom(padding: buttonPadding),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(padding: buttonPadding),
    ),
  );
}

Color markedDotColor({required Brightness brightness}) {
  switch (brightness) {
    case Brightness.light:
      return Colors.yellow.shade800;
    case Brightness.dark:
      return Colors.orange;
  }
}

Color markedTextColor({required Brightness brightness}) {
  switch (brightness) {
    case Brightness.light:
      return Colors.yellow.shade600;
    case Brightness.dark:
      return Colors.orange.shade800;
  }
}
