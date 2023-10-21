import 'preferences.dart';

import 'dart:convert';

abstract class MapPreference<K, V> {
  MapPreference({
    required this.pref,
    required this.defaultValue,
  });

  final String pref;
  final Map<K, V> defaultValue;

  Future<void> _set(Map<K, V> customList) async {
    String mapToStr = json.encode(customList);
    await Preferences.setPreference(pref, mapToStr);
  }

  Future<void> set(K key, V value) async {
    final map = get();
    map[key] = value;
    _set(map);
  }

  Future<void> remove(K key) async {
    final map = get();
    map.remove(key);
    _set(map);
  }

  Map<K, V> get() {
    Map strToMap = json.decode(Preferences.getPreferencesEntry(
      pref,
      defaultValue: json.encode(defaultValue),
    ));

    Map<K, V> mapToTyped = {};
    mapToTyped.addEntries(
      strToMap.entries.map((e) => MapEntry(e.key as K, e.value as V)),
    );

    return mapToTyped;
  }
}
