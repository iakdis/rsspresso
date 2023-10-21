import 'dart:convert';

import 'list_pref.dart';
import 'preferences.dart';

/// O is the object that will be saved as a map. V is a custom value that is
/// used to check for equality in add() and remove()
abstract class ListOfMapsPreference<O, V> extends ListPreference<O, V> {
  ListOfMapsPreference({
    required String pref,
    required List<O> defaultValue,
    this.existsException,
  }) : super(pref: pref, defaultValue: defaultValue);

  final Exception? existsException;

  Map toJson(O entry);
  O fromJson(Map entry);

  @override
  Future<void> set(List<O> list) async {
    final listOfMaps = <Map>[];
    for (var entry in list) {
      listOfMaps.add(toJson(entry));
    }

    final mapToStr = json.encode(listOfMaps);
    await Preferences.setPreference(pref, mapToStr);
  }

  @override
  List<O> get() {
    List decodedList = json.decode(Preferences.getPreferencesEntry(
      pref,
      defaultValue: json.encode(defaultValue),
    ));

    final list = <O>[];
    for (final entry in decodedList) {
      list.add(fromJson(entry as Map));
    }
    return list;
  }

  Future<void> addIfNotExisting(V value) async {
    final list = get();
    if (list.where((entry) => whereCondition(entry, value)).isEmpty) {
      await set([...list, objectToAdd(value)]);
    } else {
      if (existsException != null) {
        throw existsException!;
      }
    }
  }
}
