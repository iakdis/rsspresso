import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rssPresso/src/widgets/appbar/refresh.dart';

import '../../providers/refresh_provider.dart';
import '../../providers/search_provider.dart';
import 'card_item.dart';

class ArticleCardViewMobile extends ConsumerStatefulWidget {
  const ArticleCardViewMobile({super.key});

  @override
  ConsumerState<ArticleCardViewMobile> createState() =>
      _ArticleCardViewMobileState();
}

class _ArticleCardViewMobileState extends ConsumerState<ArticleCardViewMobile> {
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
        child: GridView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 12.0,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 1.4 / 1.0,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount: ref.watch(searchedArticlesProvider).length,
          itemBuilder: (context, index) => CardItem(
            article: ref.watch(searchedArticlesProvider).elementAt(index),
            isMobile: true,
          ),
        ),
      ),
    );
  }
}
