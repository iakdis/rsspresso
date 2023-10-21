import 'package:flutter/material.dart';

import 'theme_menu.dart';

class AppTab extends StatelessWidget {
  const AppTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      children: [
        Text(
          'App settings',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const ListTile(
          title: Text('Theme'),
          subtitle: Text('Change the app theme'),
          contentPadding: EdgeInsets.all(0),
          trailing: ThemeMenu(),
        ),
        const Divider(),
      ],
    );
  }
}
