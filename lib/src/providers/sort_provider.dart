import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/article.dart';
import 'filter_provider.dart';

class SortedListNotifier extends Notifier<List<Article>> {
  @override
  List<Article> build() {
    // Return the default type
    return [];
  }

  List<Article> byDate({required List<Article> articles}) {
    final filteredList =
        ref.read(filterProvider.notifier).filterArticles(articles);

    return filteredList
      ..sort(
        (aValue, bValue) {
          final a = aValue.date;
          final b = bValue.date;
          return b.compareTo(a);
        },
      );
  }
}

final sortProvider = NotifierProvider<SortedListNotifier, List<Article>>(() {
  return SortedListNotifier();
});
