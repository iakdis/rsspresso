import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/article.dart';

final currentArticlesProvider = StateProvider<LinkedList<Article>>(
  // Return the default type
  (ref) => LinkedList<Article>(),
);

final allArticlesProvider = StateProvider<List<Article>>(
  // Return the default type
  (ref) => [],
);
