import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/refresh_provider.dart';
import '../../providers/search_provider.dart';
import '../appbar/refresh.dart';
import '../list/list_item.dart';

class ArticleCompactViewMobile extends ConsumerStatefulWidget {
  const ArticleCompactViewMobile({super.key});

  @override
  ConsumerState<ArticleCompactViewMobile> createState() =>
      _ArticleCompactViewMobileState();
}

class _ArticleCompactViewMobileState
    extends ConsumerState<ArticleCompactViewMobile> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      child: RefreshIndicator(
        onRefresh: ref.watch(isRefreshingProvider)
            ? () async {}
            : () async => RefreshButton.refresh(ref: ref),
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(height: 0.0),
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          controller: scrollController,
          itemCount: ref.watch(searchedArticlesProvider).length,
          itemBuilder: (context, index) => ListItem(
            article: ref.watch(searchedArticlesProvider).elementAt(index),
            openInNew: true,
          ),
        ),
      ),
    );
  }
}
