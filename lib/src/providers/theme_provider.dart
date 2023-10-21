import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/preferences/preferences.dart';

final themeProvider = StateProvider<ThemeMode>(
  // Return the default type
  (ref) => ThemeMode.values.byName(PrefThemeMode().get()),
);
