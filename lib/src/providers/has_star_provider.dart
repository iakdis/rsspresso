import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/preferences/preferences.dart';

class HasStarNotifier extends Notifier<Map<String, bool>> {
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

  Map<String, bool> fromPrefs() => PrefHasStar().get();
}

final hasStarProvider =
    NotifierProvider<HasStarNotifier, Map<String, bool>>(() {
  return HasStarNotifier();
});
