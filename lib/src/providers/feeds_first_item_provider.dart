import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/preferences/preferences.dart';

class FeedsFirstItemNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() {
    // Return the default type
    return fromPrefs();
  }

  String? get(String key) => state[key];

  Future<void> set(String feedUrl, String item) async {
    final map = {...state};
    map[feedUrl] = item;
    state = map;

    return PrefFeedsFirstItem().set(feedUrl, item);
  }

  void refresh() {
    state = {};
    state = fromPrefs();
  }

  Map<String, String> fromPrefs() => PrefFeedsFirstItem().get();
}

final feedsFirstItemProvider =
    NotifierProvider<FeedsFirstItemNotifier, Map<String, String>>(() {
  return FeedsFirstItemNotifier();
});
