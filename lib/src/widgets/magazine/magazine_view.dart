import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/search_provider.dart';
import 'magazine_item.dart';

class ArticleMagazineView extends ConsumerStatefulWidget {
  const ArticleMagazineView({super.key});

  @override
  ConsumerState<ArticleMagazineView> createState() =>
      _ArticleMagazineViewState();
}

class _ArticleMagazineViewState extends ConsumerState<ArticleMagazineView> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      child: LayoutBuilder(builder: (context, constraints) {
        const maxWidth = 800;
        final width = constraints.maxWidth;
        final padding = (width > maxWidth) ? (width - maxWidth) / 2 : 0.0;

        return ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          padding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: 16.0,
          ),
          controller: scrollController,
          itemCount: ref.watch(searchedArticlesProvider).length,
          itemBuilder: (context, index) => MagazineItem(
              article: ref.watch(searchedArticlesProvider).elementAt(index)),
        );
      }),
    );
  }
}
