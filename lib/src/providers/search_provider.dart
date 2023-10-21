import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/article.dart';

final searchedArticlesProvider = StateProvider<LinkedList<Article>>(
  // Return the default type
  (ref) => LinkedList(),
);

final searchProvider = StateProvider<String>(
  // Return the default type
  (ref) => '',
);
