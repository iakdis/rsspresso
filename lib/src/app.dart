import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/theme_provider.dart';
import 'themes/theme.dart';
import 'pages/page.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'rssPresso',
      theme: theme(context: context, brightness: Brightness.light),
      darkTheme: theme(context: context, brightness: Brightness.dark),
      themeMode: ref.watch(themeProvider),
      home: const AppPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
