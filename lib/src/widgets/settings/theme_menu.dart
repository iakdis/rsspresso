import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/theme_provider.dart';
import '../../utils/preferences/preferences.dart';

class ThemeMenu extends ConsumerStatefulWidget {
  const ThemeMenu({super.key});

  @override
  ThemeMenuState createState() => ThemeMenuState();
}

class ThemeMenuState extends ConsumerState<ThemeMenu> {
  DropdownMenuItem<ThemeMode> menuItem({
    required ThemeMode theme,
    required IconData icon,
    required String text,
  }) {
    return DropdownMenuItem<ThemeMode>(
      value: theme,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8.0),
          Text(text),
        ],
      ),
    );
  }

  IconData getIconPerView(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.system:
        return Icons.settings_display;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<ThemeMode>(
        onChanged: (theme) {
          if (theme == null) return;
          PrefThemeMode().set(theme.name);
          ref.read(themeProvider.notifier).state = theme;
        },
        value: ref.watch(themeProvider),
        items: [
          menuItem(
            theme: ThemeMode.system,
            icon: getIconPerView(ThemeMode.system),
            text: 'System',
          ),
          menuItem(
            theme: ThemeMode.light,
            icon: getIconPerView(ThemeMode.light),
            text: 'Light',
          ),
          menuItem(
            theme: ThemeMode.dark,
            icon: getIconPerView(ThemeMode.dark),
            text: 'Dark',
          ),
        ],
      ),
    );
  }
}
