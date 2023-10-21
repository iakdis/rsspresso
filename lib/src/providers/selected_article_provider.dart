import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/article.dart';

final selectedArticleProvider = StateProvider<Article?>(
  // Return the default type
  (ref) => null,
);
