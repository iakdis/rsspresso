import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/feed.dart';

final selectedFeedProvider = StateProvider<Feed?>(
  // Return the default type
  (ref) => null,
);
