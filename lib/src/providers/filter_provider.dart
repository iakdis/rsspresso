import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/article.dart';
import '../models/filter.dart';
import '../utils/preferences/preferences.dart';
import 'has_read_provider.dart';
import 'has_star_provider.dart';

class FilteredListNotifier extends Notifier<Filter> {
  @override
  Filter build() {
    // Return the default type
    return Filter.values.byName(PrefFilter().get());
  }

  void set(Filter filter) {
    state = filter;
  }

  List<Article> filterArticles(List<Article> articles) {
    switch (state) {
      case Filter.unreadOnly:
        return _onlyUnread(articles);
      case Filter.starOnly:
        return _onlyStar(articles);
      default:
        return articles;
    }
  }

  List<Article> _onlyUnread(List<Article> articles) {
    final list = <Article>[];

    for (final article in articles) {
      final hasRead = ref.watch(hasReadProvider.notifier).get(article.id);

      if (!hasRead) list.add(article);
    }
    return list;
  }

  List<Article> _onlyStar(List<Article> articles) {
    final list = <Article>[];

    for (final article in articles) {
      final hasStar = ref.watch(hasStarProvider.notifier).get(article.id);

      if (hasStar) list.add(article);
    }
    return list;
  }
}

final filterProvider = NotifierProvider<FilteredListNotifier, Filter>(() {
  return FilteredListNotifier();
});
