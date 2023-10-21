import 'preferences.dart';

abstract class ValuePreference<T> {
  ValuePreference({
    required this.pref,
    required this.defaultValue,
  });

  final String pref;
  final T defaultValue;

  Future<void> set(T value) async =>
      await Preferences.setPreference(pref, value);

  T get() => Preferences.getPreferencesEntry(pref, defaultValue: defaultValue);
}
