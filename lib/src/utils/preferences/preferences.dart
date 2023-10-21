import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/feed.dart';
import '../../models/filter.dart';
import '../globals.dart';
import 'list_of_maps_pref.dart';
import 'map_pref.dart';
import 'value_pref.dart';

class Preferences {
  static SharedPreferences? _preferences;

  // Init prefs
  static Future<void> init() async =>
      _preferences = await SharedPreferences.getInstance();

  // Reset prefs
  static Future<void> clearPreferences() async => await _preferences!.clear();

  // Export prefs
  static String getAllPreferences() {
    var object = json.decode(_preferences!.getString(prefPreferences) ?? '');
    return const JsonEncoder.withIndent('  ').convert(object);
  }

  // Import prefs
  static Future<void> setAllPreferences(String preferences) async {
    await _preferences!.setString(prefPreferences, preferences);
  }

  // Set one pref
  static Future<void> setPreference(String key, dynamic value) async {
    final preferences = _getAllPreferences();
    preferences[key] = value;

    String fromJson = json.encode(preferences);
    await _preferences!.setString(prefPreferences, fromJson);
  }

  // Get all prefs
  static Map<String, dynamic> _getAllPreferences() {
    final Map prefs = json
        .decode(_preferences!.getString(prefPreferences) ?? json.encode({}));

    final Map<String, dynamic> allPrefs = {};
    allPrefs.addEntries(prefs.entries.map((e) => MapEntry(e.key, e.value)));

    return allPrefs;
  }

  // Get one prefs entry
  static dynamic getPreferencesEntry(String pref,
      {required dynamic defaultValue}) {
    return _getAllPreferences().containsKey(pref)
        ? _getAllPreferences()[pref]
        : defaultValue;
  }
}

class PrefThemeMode extends ValuePreference<String> {
  PrefThemeMode()
      : super(
          pref: prefThemeMode,
          defaultValue: ThemeMode.system.name,
        );
}

class PrefLanguage extends ValuePreference<String> {
  PrefLanguage()
      : super(
          pref: prefLanguage,
          defaultValue: 'en',
        );
}

class PrefHomeView extends ValuePreference<String?> {
  PrefHomeView()
      : super(
          pref: prefHomeView,
          defaultValue: null,
        );
}

class PrefHasRead extends MapPreference<String, bool> {
  PrefHasRead()
      : super(
          pref: prefHasRead,
          defaultValue: {},
        );
}

class PrefFavicons extends MapPreference<String, String> {
  PrefFavicons()
      : super(
          pref: prefFavicons,
          defaultValue: {},
        );
}

class PrefFeedsPaths extends MapPreference<String, String> {
  PrefFeedsPaths()
      : super(
          pref: prefFeedsPaths,
          defaultValue: {},
        );
}

class PrefFeeds extends ListOfMapsPreference<Feed, String> {
  PrefFeeds()
      : super(
          pref: prefFeeds,
          defaultValue: [],
          existsException: FeedAlreadyExistsException(),
        );

  @override
  Map toJson(Feed entry) {
    return entry.toJson();
  }

  @override
  Feed fromJson(Map entry) {
    return Feed.fromJson(entry);
  }

  @override
  bool whereCondition(entry, value) {
    return entry.url == value;
  }

  @override
  Feed objectToAdd(value) {
    return Feed(url: value);
  }
}

class PrefHasStar extends MapPreference<String, bool> {
  PrefHasStar()
      : super(
          pref: prefHasStar,
          defaultValue: {},
        );
}

class PrefFilter extends ValuePreference<String> {
  PrefFilter()
      : super(
          pref: prefFilter,
          defaultValue: Filter.allArticles.name,
        );
}

class PrefFontSize extends ValuePreference<double> {
  PrefFontSize()
      : super(
          pref: prefFontSize,
          defaultValue: 16,
        );
}

class PrefTextDirection extends ValuePreference<String> {
  PrefTextDirection()
      : super(
          pref: prefTextDirection,
          defaultValue: TextDirection.ltr.name,
        );
}

class PrefFeedsTitles extends MapPreference<String, String> {
  PrefFeedsTitles()
      : super(
          pref: prefFeedsTitles,
          defaultValue: {},
        );
}

class PrefFeedsFirstItem extends MapPreference<String, String> {
  PrefFeedsFirstItem()
      : super(
          pref: prefFeedsFirstItem,
          defaultValue: {},
        );
}
