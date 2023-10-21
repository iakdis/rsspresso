import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/article.dart';
import '../providers/articles_provider.dart';
import '../providers/search_provider.dart';
import '../providers/sort_provider.dart';

class ArticleSearchBar extends ConsumerStatefulWidget {
  const ArticleSearchBar({super.key});

  @override
  ConsumerState<ArticleSearchBar> createState() => _ArticleSearchBarState();
}

class _ArticleSearchBarState extends ConsumerState<ArticleSearchBar> {
  final TextEditingController controller = TextEditingController();

  bool searchConditions({required String search, required Article article}) {
    final title = article.title.toLowerCase().contains(search.toLowerCase());

    return title;
  }

  void onChanged(String search) {
    ref.read(searchProvider.notifier).state = search;
    final articles = ref.watch(currentArticlesProvider);
    final sortedArticles =
        ref.read(sortProvider.notifier).byDate(articles: articles.toList());

    final results = LinkedList<Article>();
    for (final linkedArticle in sortedArticles) {
      final article = Article.copyWith(article: linkedArticle);

      if (search.isEmpty ||
          searchConditions(search: search, article: article)) {
        results.add(article);
      }
    }
    ref.read(searchedArticlesProvider.notifier).state = results;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onTapOutside: ((event) => FocusScope.of(context).unfocus()),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 40),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        prefixIcon: const Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 12.0),
          child: Icon(Icons.search),
        ),
        suffixIcon: ref.watch(searchProvider).isNotEmpty
            ? Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 6.0),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      controller.text = '';
                      onChanged('');
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              )
            : null,
        hintText: 'Search',
      ),
    );
  }
}
