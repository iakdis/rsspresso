import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/preferences/preferences.dart';

class FeedsTitlesNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() {
    // Return the default type
    return fromPrefs();
  }

  String? get(String key) => state[key];

  Future<void> set(String feedUrl, String title) async {
    final map = {...state};
    map[feedUrl] = title;
    state = map;

    return PrefFeedsTitles().set(feedUrl, title);
  }

  void refresh() {
    state = {};
    state = fromPrefs();
  }

  Map<String, String> fromPrefs() => PrefFeedsTitles().get();
}

final feedsTitlesProvider =
    NotifierProvider<FeedsTitlesNotifier, Map<String, String>>(() {
  return FeedsTitlesNotifier();
});
