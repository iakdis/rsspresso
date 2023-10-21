import 'preferences.dart';

import 'dart:convert';

/// O is the object that will be saved as a map. V is a custom value that is
/// used to check for equality in add() and remove()
abstract class ListPreference<O, V> {
  ListPreference({
    required this.pref,
    required this.defaultValue,
  });

  final String pref;
  final List<O> defaultValue;

  bool whereCondition(O entry, V value);
  O objectToAdd(V value);

  Future<void> set(List<O> list) async {
    final mapToStr = json.encode(list);
    await Preferences.setPreference(pref, mapToStr);
  }

  List<O> get() {
    List decodedList = json.decode(Preferences.getPreferencesEntry(
      pref,
      defaultValue: json.encode(defaultValue),
    ));

    final list = <O>[];
    for (final entry in decodedList) {
      list.add(entry as O);
    }
    return list;
  }

  Future<void> add(V value) async {
    final list = get();
    await set([...list, objectToAdd(value)]);
  }

  Future<void> remove(V value) async {
    final list = [...get()];
    list.removeWhere((entry) => whereCondition(entry, value));
    await set(list);
  }
}
