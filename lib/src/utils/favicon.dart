import 'dart:io';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'cache.dart';
import 'is_http.dart';

Future<String> fetchFavicon({required String url}) async {
  final uri = Uri.parse(url);

  if (Cache.loadFaviconPrefs(uri: uri) != null &&
      await File(Cache.loadFaviconPrefs(uri: uri)!).exists()) {
    return Cache.loadFaviconPrefs(uri: uri)!;
  }

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final body = response.body;
    final document = parse(body);

    final icon = document.querySelector("link[rel*='icon']");
    final href = icon?.attributes['href'].toString();
    String? path;

    if (href != null) {
      // Use href (url or path)
      path =
          isHTTP(href) ? href : url.substring(0, url.indexOf(uri.path)) + href;
    } else {
      // Otherwise use the favicon.ico
      path = p.join(url.substring(0, url.indexOf(uri.path)), 'favicon.ico');
    }

    await Cache.saveFaviconFile(
      articleUri: uri,
      faviconUri: Uri.parse(path),
    );

    return path;
  } else {
    throw Exception('Failed to load');
  }
}
