import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/feed.dart';
import '../utils/preferences/preferences.dart';

final feedsProvider = StateProvider<List<Feed>>(
  // Return the default type
  (ref) => PrefFeeds().get(),
);
