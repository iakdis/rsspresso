import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../models/feed.dart';
import '../models/rss.dart';
import '../providers/feeds_first_item_provider.dart';
import '../providers/feeds_titles_provider.dart';
import 'preferences/preferences.dart';

class Cache {
  static Future<Directory> _getCacheDirectory() async {
    final cache = await getApplicationCacheDirectory();
    final custom = p.join(
      cache.path,
      'rsspresso_cache',
    );
    return await Directory(custom).create();
  }

  static String _feedFolderPath({required Uri feedsUri}) {
    final path = feedsUri
        .toString()
        .substring(
            feedsUri.toString().indexOf(feedsUri.authority)) // From authority
        .replaceAll('/', '-'); // Replace path seperators with "-"

    return path;
  }

  static Future<String> _feedPath({required Uri feedsUri}) async {
    final cacheDirectory = await _getCacheDirectory();
    final feedsPath = p.join(
      cacheDirectory.path,
      'feeds',
    );
    final titlePath = p.join(
      feedsPath,
      _feedFolderPath(feedsUri: feedsUri),
    );
    return titlePath;
  }

  static Future<String> _getFeedFilePath({required Uri feedsUri}) async {
    final feedPath = await _feedPath(feedsUri: feedsUri);
    final directory = await Directory(feedPath).create(recursive: true);

    String filePath;
    try {
      filePath = p.join(directory.path, feedsUri.pathSegments.last);
    } catch (e) {
      filePath = p.join(directory.path,
          feedsUri.hasQuery ? feedsUri.query : feedsUri.authority);
    }

    return filePath;
  }

  static Future<void> writeCachedFeed({
    required Uri feedsUri,
    required String contents,
  }) async {
    final filePath = await _getFeedFilePath(feedsUri: feedsUri);
    final file = await File(filePath).create();

    await file.writeAsString(contents);

    PrefFeedsPaths().set(_feedFolderPath(feedsUri: feedsUri), filePath);
  }

  static Future<void> deleteCachedFeed({required Uri feedsUri}) async {
    final feedPath = await _feedPath(feedsUri: feedsUri);
    if (await Directory(feedPath).exists()) {
      await Directory(feedPath).delete(recursive: true);
    }
    PrefFeedsPaths().remove(_feedFolderPath(feedsUri: feedsUri));
  }

  static bool containsFeedPath({required Uri feedsUri}) {
    final articlesPaths = PrefFeedsPaths().get();
    final key = _feedFolderPath(feedsUri: feedsUri);
    return articlesPaths.containsKey(key);
  }

  static Future<GeneralFeed?> readCachedFeed({required Uri feedsUri}) async {
    if (containsFeedPath(feedsUri: feedsUri)) {
      final filePath = await _getFeedFilePath(feedsUri: feedsUri);
      final file = File(filePath);

      if (!await file.exists()) return null;

      final contents = await file.readAsString();
      try {
        final xmlDocument = GeneralFeed.parse(contents);
        return xmlDocument;
      } catch (e) {
        return null;
      }
    } else {
      return null;
    }
  }

  static Future<Feed> loadFeed({
    required WidgetRef ref,
    required String url,
  }) async {
    Future<GeneralFeed> document() async {
      GeneralFeed? document;
      final cachedFeed = await readCachedFeed(feedsUri: Uri.parse(url));
      if (cachedFeed != null) {
        document = cachedFeed;
      } else {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          document = GeneralFeed.parse(response.body);
        }
      }
      return document ?? const GeneralFeed();
    }

    String? author;
    final feedsTitles = ref.read(feedsTitlesProvider.notifier);
    if (feedsTitles.get(url) != null) {
      author = feedsTitles.get(url);
    } else {
      author = (await document()).title!;
      await feedsTitles.set(url, author);
    }

    String? firstItem;
    final feedsFirstItem = ref.read(feedsFirstItemProvider.notifier);
    if (feedsFirstItem.get(url) != null) {
      firstItem = feedsFirstItem.get(url);
    } else {
      final items = (await document()).items;
      firstItem = items[0].link!;
      await feedsFirstItem.set(url, firstItem);
    }

    return Feed(
      url: url,
      author: author,
      favicon: firstItem,
    );
  }

  static String? loadFaviconPrefs({required Uri uri}) {
    final favicons = PrefFavicons().get();
    final key = uri.authority;

    if (favicons.containsKey(key)) {
      return favicons[key];
    } else {
      return null;
    }
  }

  static Future<String> _faviconDirectory({required Uri articleUri}) async {
    final cacheDirectory = await _getCacheDirectory();
    final faviconsPath = p.join(
      cacheDirectory.path,
      'favicons',
    );
    return p.join(
      faviconsPath,
      articleUri.authority,
    );
  }

  static Future<void> deleteFavicon({required Uri feedsUri}) async {
    final document = await readCachedFeed(feedsUri: feedsUri);
    if (document == null) return;

    final items = document.items;
    if (items.isEmpty) return;

    final articleUri = items[0].link!;
    final faviconPath =
        await _faviconDirectory(articleUri: Uri.parse(articleUri));
    if (await Directory(faviconPath).exists()) {
      await Directory(faviconPath).delete(recursive: true);
    }
  }

  static Future<void> saveFaviconFile({
    required Uri articleUri,
    required Uri faviconUri,
  }) async {
    final faviconFolder = await _faviconDirectory(articleUri: articleUri);
    final customDirectory =
        await Directory(faviconFolder).create(recursive: true);
    String filePath;
    try {
      filePath = p.join(customDirectory.path, faviconUri.pathSegments.last);
    } catch (e) {
      filePath = p.join(customDirectory.path,
          faviconUri.hasQuery ? faviconUri.query : faviconUri.authority);
    }
    final file = File(filePath);

    final response = await http.get(faviconUri);
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      PrefFavicons().set(articleUri.authority, filePath);
    } else {
      throw Exception('Failed to load');
    }
  }
}
