import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/home_view.dart';
import '../../providers/view_provider.dart';
import '../../utils/globals.dart';
import '../../utils/preferences/preferences.dart';

class ViewMenuModel {
  ViewMenuModel({
    required this.view,
    required this.icon,
    required this.text,
  });

  final HomeView view;
  final IconData icon;
  final String text;
}

class ViewButton extends ConsumerWidget {
  const ViewButton({super.key});

  CheckedPopupMenuItem<HomeView> menuItem({
    required WidgetRef ref,
    required ViewMenuModel viewModel,
  }) {
    return CheckedPopupMenuItem<HomeView>(
      value: viewModel.view,
      checked: ref.watch(viewProvider) == viewModel.view,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Icon(viewModel.icon),
          const SizedBox(width: 8.0),
          Text(viewModel.text),
        ],
      ),
    );
  }

  static Map<HomeView, IconData> get iconPerView {
    return {
      // Desktop
      HomeView.cardView: Icons.grid_view,
      HomeView.listView: Icons.view_list,
      HomeView.magazineView: Icons.newspaper,
      HomeView.compactView: Icons.list,

      // Mobile
      HomeView.cardViewMobile: Icons.grid_view,
      HomeView.compactViewMobile: Icons.list,
    };
  }

  static Map<HomeView, ViewMenuModel> get viewMenuModel {
    return {
      // Desktop
      HomeView.cardView: ViewMenuModel(
        view: HomeView.cardView,
        icon: iconPerView[HomeView.cardView]!,
        text: 'Card view',
      ),
      HomeView.listView: ViewMenuModel(
        view: HomeView.listView,
        icon: iconPerView[HomeView.listView]!,
        text: 'List view',
      ),
      HomeView.magazineView: ViewMenuModel(
        view: HomeView.magazineView,
        icon: iconPerView[HomeView.magazineView]!,
        text: 'Magazine view',
      ),
      HomeView.compactView: ViewMenuModel(
        view: HomeView.compactView,
        icon: iconPerView[HomeView.compactView]!,
        text: 'Compact view',
      ),

      // Mobile
      HomeView.cardViewMobile: ViewMenuModel(
        view: HomeView.cardViewMobile,
        icon: iconPerView[HomeView.cardViewMobile]!,
        text: 'Card view',
      ),
      HomeView.compactViewMobile: ViewMenuModel(
        view: HomeView.compactViewMobile,
        icon: iconPerView[HomeView.compactViewMobile]!,
        text: 'Compact view',
      ),
    };
  }

  static void setView({required WidgetRef ref, required HomeView view}) {
    PrefHomeView().set(view.name);
    ref.read(viewProvider.notifier).state = view;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;

    return PopupMenuButton<HomeView>(
      initialValue: ref.watch(viewProvider),
      tooltip: 'Change view',
      icon: const Icon(Icons.grid_on),
      onSelected: (HomeView view) => setView(ref: ref, view: view),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<HomeView>>[
        // Desktop
        if (width > ScreenSize.mobileWidth)
          menuItem(
            ref: ref,
            viewModel: viewMenuModel[HomeView.cardView]!,
          ),
        if (width > ScreenSize.mobileWidth)
          menuItem(
            ref: ref,
            viewModel: viewMenuModel[HomeView.listView]!,
          ),
        if (width > ScreenSize.mobileWidth)
          menuItem(
            ref: ref,
            viewModel: viewMenuModel[HomeView.magazineView]!,
          ),
        if (width > ScreenSize.mobileWidth)
          menuItem(
            ref: ref,
            viewModel: viewMenuModel[HomeView.compactView]!,
          ),

        // Mobile
        if (width <= ScreenSize.mobileWidth)
          menuItem(
            ref: ref,
            viewModel: viewMenuModel[HomeView.cardViewMobile]!,
          ),
        if (width <= ScreenSize.mobileWidth)
          menuItem(
            ref: ref,
            viewModel: viewMenuModel[HomeView.compactViewMobile]!,
          ),
      ],
    );
  }
}
