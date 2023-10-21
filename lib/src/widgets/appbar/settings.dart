import 'package:flutter/material.dart';

import '../../pages/settings_page.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  static void Function() open({required BuildContext context}) =>
      () => openSettings(context: context);

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: open(context: context),
      icon: const Icon(Icons.settings),
    );
  }
}
