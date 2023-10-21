import 'package:flutter/material.dart';

import '../utils/blur_page.dart';
import '../widgets/settings/app_tab.dart';
import '../widgets/settings/feed_tab.dart';
import '../widgets/settings/info_tab.dart';
import '../utils/globals.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late final TabController controller;
  final List<Widget> tabs = const [
    Tab(text: 'Feeds', icon: Icon(Icons.feed)),
    Tab(text: 'Settings', icon: Icon(Icons.settings)),
    Tab(text: 'About', icon: Icon(Icons.info)),
  ];

  @override
  void initState() {
    super.initState();
    controller = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Builder(builder: (context) {
        return ClipRRect(
          borderRadius:
              MediaQuery.of(context).size.width > ScreenSize.tabletWidth
                  ? BorderRadius.circular(6.0)
                  : BorderRadius.zero,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              titleSpacing: 4.0,
              automaticallyImplyLeading: false,
              title: Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: TabBar(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                tabs: tabs,
              ),
            ),
            body: TabBarView(
              controller: controller,
              children: [
                FeedTab(scaffoldContext: context),
                const AppTab(),
                const InfoTab(),
              ],
            ),
          ),
        );
      }),
    );
  }
}

void openSettings({required BuildContext context}) {
  Navigator.of(context).push(blurPage(
    page: const SettingsPage(),
    maxWidth: PageSize.settingsWidth,
  ));
}
