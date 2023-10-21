import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/preferences/preferences.dart';

class HasReadNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    // Return the default type
    return fromPrefs();
  }

  bool get(String key) => state[key] ?? false;

  void refresh() {
    state = {};
    state = fromPrefs();
  }

  Map<String, bool> fromPrefs() => PrefHasRead().get();
}

final hasReadProvider =
    NotifierProvider<HasReadNotifier, Map<String, bool>>(() {
  return HasReadNotifier();
});
