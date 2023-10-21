import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/search_provider.dart';
import 'compact_item.dart';

class ArticleCompactView extends ConsumerStatefulWidget {
  const ArticleCompactView({super.key});

  @override
  ConsumerState<ArticleCompactView> createState() => _ArticleCompactViewState();
}

class _ArticleCompactViewState extends ConsumerState<ArticleCompactView> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      child: ListView.separated(
        separatorBuilder: (context, index) => const Divider(height: 0.0),
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        controller: scrollController,
        itemCount: ref.watch(searchedArticlesProvider).length,
        itemBuilder: (context, index) => CompactItem(
            article: ref.watch(searchedArticlesProvider).elementAt(index)),
      ),
    );
  }
}
