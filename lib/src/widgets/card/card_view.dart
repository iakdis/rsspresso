import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/search_provider.dart';
import '../../utils/globals.dart';
import 'card_item.dart';

class ArticleCardView extends ConsumerStatefulWidget {
  const ArticleCardView({super.key});

  @override
  ConsumerState<ArticleCardView> createState() => _ArticleCardViewState();
}

class _ArticleCardViewState extends ConsumerState<ArticleCardView> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      child: GridView.builder(
        controller: scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: width > ScreenSize.tabletWidth ? 32.0 : 16.0,
          vertical: 16.0,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 270.0,
          mainAxisExtent: 270.0,
          childAspectRatio: 1.0,
          mainAxisSpacing: width > ScreenSize.tabletWidth ? 24.0 : 8.0,
          crossAxisSpacing: width > ScreenSize.tabletWidth ? 24.0 : 8.0,
        ),
        itemCount: ref.watch(searchedArticlesProvider).length,
        itemBuilder: (context, index) => CardItem(
            article: ref.watch(searchedArticlesProvider).elementAt(index)),
      ),
    );
  }
}
