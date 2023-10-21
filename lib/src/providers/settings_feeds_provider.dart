import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsFeedsNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    // Return the default type
    return {};
  }

  void set(String key, bool value) {
    final map = {...state};
    map[key] = value;
    state = map;
  }

  void remove(String key) {
    final map = {...state};
    map.remove(key);
    state = map;
  }
}

final settingsFeedsProvider =
    NotifierProvider<SettingsFeedsNotifier, Map<String, bool>>(() {
  return SettingsFeedsNotifier();
});
