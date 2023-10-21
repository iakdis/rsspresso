import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../pages/article_page.dart';
import '../../providers/search_provider.dart';
import 'list_item.dart';

class ArticleListView extends ConsumerStatefulWidget {
  const ArticleListView({super.key});

  @override
  ConsumerState<ArticleListView> createState() => _ArticleCompactViewState();
}

class _ArticleCompactViewState extends ConsumerState<ArticleListView> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 400,
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: ListView.separated(
              separatorBuilder: (context, index) => const Divider(height: 0.0),
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              controller: scrollController,
              itemCount: ref.watch(searchedArticlesProvider).length,
              itemBuilder: (context, index) => ListItem(
                  article:
                      ref.watch(searchedArticlesProvider).elementAt(index)),
            ),
          ),
        ),
        const VerticalDivider(width: 2),
        const Expanded(child: ArticlePage(openAsDialog: false)),
      ],
    );
  }
}
