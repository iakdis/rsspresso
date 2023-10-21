import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/filter.dart';
import '../../providers/filter_provider.dart';
import '../../providers/load_articles_provider.dart';
import '../../utils/preferences/preferences.dart';

class FilterMenuModel {
  FilterMenuModel({
    required this.filter,
    required this.icon,
    required this.text,
  });

  final Filter filter;
  final IconData icon;
  final String text;
}

class FilterButton extends ConsumerWidget {
  const FilterButton({super.key});

  CheckedPopupMenuItem<Filter> menuItem({
    required WidgetRef ref,
    required FilterMenuModel filterModel,
  }) {
    return CheckedPopupMenuItem<Filter>(
      value: filterModel.filter,
      checked: ref.watch(filterProvider) == filterModel.filter,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Icon(filterModel.icon),
          const SizedBox(width: 8.0),
          Text(filterModel.text),
        ],
      ),
    );
  }

  static Map<Filter, IconData> get iconPerView {
    return {
      Filter.allArticles: Icons.filter_alt_outlined,
      Filter.unreadOnly: Icons.visibility_off_outlined,
      Filter.starOnly: Icons.star,
    };
  }

  static Map<Filter, FilterMenuModel> get filterMenuModel {
    return {
      Filter.allArticles: FilterMenuModel(
        filter: Filter.allArticles,
        icon: iconPerView[Filter.allArticles]!,
        text: 'All articles',
      ),
      Filter.unreadOnly: FilterMenuModel(
        filter: Filter.unreadOnly,
        icon: iconPerView[Filter.unreadOnly]!,
        text: 'Unread only',
      ),
      Filter.starOnly: FilterMenuModel(
        filter: Filter.starOnly,
        icon: iconPerView[Filter.starOnly]!,
        text: 'Marked only',
      ),
    };
  }

  static void setFilter({required WidgetRef ref, required Filter filter}) {
    PrefFilter().set(filter.name);
    ref.read(filterProvider.notifier).set(filter);
    ref.read(loadArticlesProvider.notifier).refreshArticles(LoadType.cached);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<Filter>(
      initialValue: ref.watch(filterProvider),
      tooltip: 'Filter',
      icon: Icon(ref.watch(filterProvider) == Filter.allArticles
          ? Icons.filter_alt_outlined
          : Icons.filter_alt),
      onSelected: (Filter filter) => setFilter(ref: ref, filter: filter),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Filter>>[
        menuItem(
          ref: ref,
          filterModel: filterMenuModel[Filter.allArticles]!,
        ),
        menuItem(
          ref: ref,
          filterModel: filterMenuModel[Filter.unreadOnly]!,
        ),
        menuItem(
          ref: ref,
          filterModel: filterMenuModel[Filter.starOnly]!,
        ),
      ],
    );
  }
}
