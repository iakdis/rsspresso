import 'package:flutter/material.dart' hide SubmenuButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/filter.dart';
import '../../models/home_view.dart';
import '../../providers/filter_provider.dart';
import '../../providers/refresh_provider.dart';
import '../../providers/view_provider.dart';
import '../../utils/globals.dart';
import '../menu.dart';
import 'filter.dart';
import 'refresh.dart';
import 'settings.dart';
import 'view.dart';

enum NavigationItems {
  refresh,
  filter,
  view,
  settings,
}

class MoreButton extends ConsumerStatefulWidget {
  const MoreButton({super.key});

  @override
  MoreButtonState createState() => MoreButtonState();
}

class MoreButtonState extends ConsumerState<MoreButton> {
  PopupMenuItem<NavigationItems> menuItem({
    required void Function()? onTap,
    required IconData icon,
    required String text,
  }) {
    return PopupMenuItem<NavigationItems>(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8.0),
          Text(text),
        ],
      ),
    );
  }

  Map<NavigationItems, IconData> get iconPerView {
    return {
      NavigationItems.refresh: Icons.refresh,
      NavigationItems.filter: ref.watch(filterProvider) == Filter.allArticles
          ? Icons.filter_alt_outlined
          : Icons.filter_alt,
      NavigationItems.view: Icons.grid_on,
      NavigationItems.settings: Icons.settings,
    };
  }

  Widget filterButton(Filter filter) => SubmenuButton.checked(
        onPressed: () => FilterButton.setFilter(ref: ref, filter: filter),
        text: FilterButton.filterMenuModel[filter]!.text,
        icon: FilterButton.filterMenuModel[filter]!.icon,
        checked: ref.watch(filterProvider) == filter,
      );

  Widget viewButton(HomeView view) => SubmenuButton.checked(
        onPressed: () => ViewButton.setView(ref: ref, view: view),
        text: ViewButton.viewMenuModel[view]!.text,
        icon: ViewButton.viewMenuModel[view]!.icon,
        checked: ref.watch(viewProvider) == view,
      );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Menu(
      icon: Icons.more_vert,
      menuChildren: [
        const SizedBox(width: 160),
        MenuButton(
          onPressed: ref.watch(isRefreshingProvider)
              ? null
              : () => RefreshButton.refresh(ref: ref),
          icon: iconPerView[NavigationItems.refresh]!,
          text: 'Refresh',
        ),
        const Divider(height: 12),
        Submenu(
          text: 'Filter',
          icon: iconPerView[NavigationItems.filter]!,
          menuChildren: <Widget>[
            filterButton(Filter.allArticles),
            filterButton(Filter.unreadOnly),
            filterButton(Filter.starOnly),
          ],
        ),
        Submenu(
          text: 'View',
          icon: iconPerView[NavigationItems.view]!,
          menuChildren: <Widget>[
            // Desktop
            if (width > ScreenSize.mobileWidth) viewButton(HomeView.cardView),
            if (width > ScreenSize.mobileWidth)
              viewButton(HomeView.magazineView),
            if (width > ScreenSize.mobileWidth) viewButton(HomeView.listView),
            if (width > ScreenSize.mobileWidth)
              viewButton(HomeView.compactView),

            // Mobile
            if (width <= ScreenSize.mobileWidth)
              viewButton(HomeView.cardViewMobile),
            if (width <= ScreenSize.mobileWidth)
              viewButton(HomeView.compactViewMobile),
          ],
        ),
        const Divider(height: 12),
        MenuButton(
          onPressed: SettingsButton.open(context: context),
          icon: iconPerView[NavigationItems.settings]!,
          text: 'Settings',
        ),
      ],
    );
  }
}
