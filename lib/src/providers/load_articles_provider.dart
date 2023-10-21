import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:collection';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/article.dart';
import '../models/feed.dart';
import '../models/rss.dart';
import '../providers/articles_provider.dart';
import '../providers/feeds_provider.dart';
import '../providers/search_provider.dart';
import '../providers/selected_feed_provider.dart';
import '../utils/cache.dart';
import '../utils/favicon.dart';
import 'has_read_provider.dart';
import 'refresh_provider.dart';
import 'sort_provider.dart';

enum LoadType {
  online,
  cached,
  cachedAndOnline,
}

class LoadArticlesNotifier extends Notifier<Future<bool>> {
  final _formatter = DateFormat("EEE, dd MMM yyyy hh:mm:ss zzz");

  @override
  Future<bool> build() async {
    // Return the default type
    return loadCachedAndFetchedArticles();
  }

  void refreshArticles(LoadType loadType) {
    switch (loadType) {
      case LoadType.cached:
        state = loadCachedArticles();
        break;
      case LoadType.online:
        state = loadFetchedArticles();
        break;
      case LoadType.cachedAndOnline:
        state = loadCachedAndFetchedArticles();
        break;
    }
  }

  Future<List<Article>> _parseArticles({
    required GeneralFeed document,
    required Feed feed,
  }) async {
    final articles = <Article>[];
    final items = document.items;
    final author = document.title!;
    var favicon = '';

    if (items.isNotEmpty) {
      final firstItemLink = items[0].link!;
      favicon = await fetchFavicon(url: firstItemLink);
    }

    for (var i = 0; i < items.length; i++) {
      final title = items[i].title!;
      final link = items[i].link!;
      var date = DateTime.now();
      if (items[i].pubDate != null) {
        try {
          date = _formatter.parse(items[i].pubDate!);
        } catch (e) {
          date = DateTime.parse(items[i].pubDate!);
        }
      }

      final htmlContent = items[i].content ?? items[i].description ?? '';
      final textContent = parse(htmlContent).body?.text.trim() ?? '';

      final article = Article(
        title: title,
        author: author,
        link: link,
        date: date,
        textContent: textContent,
        htmlContent: htmlContent,
        favicon: favicon,
        feed: feed,
      );
      articles.add(article);
    }
    return articles;
  }

  void refreshArticlesProvider() {
    final articles = ref.watch(currentArticlesProvider);
    final sortedArticles =
        ref.read(sortProvider.notifier).byDate(articles: articles.toList());

    final results = LinkedList<Article>();
    for (final linkedArticle in sortedArticles) {
      final article = Article.copyWith(article: linkedArticle);
      results.add(article);
    }
    ref.read(searchedArticlesProvider.notifier).state = results;
  }

  Future<void> loadCachedFeed({
    required GeneralFeed document,
    required Feed feed,
    bool allArticles = false,
  }) async {
    final articles = await _parseArticles(document: document, feed: feed);
    for (var i = 0; i < articles.length; i++) {
      allArticles
          ? ref.read(allArticlesProvider).add(articles[i])
          : ref.read(currentArticlesProvider).add(articles[i]);
    }
  }

  Future<void> _fetchFeed({
    required Feed feed,
    required String body,
  }) async {
    final document = GeneralFeed.parse(body);

    final articles = await _parseArticles(document: document, feed: feed);
    for (var i = 0; i < articles.length; i++) {
      final article = articles[i];
      ref.read(currentArticlesProvider).add(article);
    }
  }

  Future<void> _writeCachedFeeds(
      {required Feed feed, required String body}) async {
    await Cache.writeCachedFeed(feedsUri: Uri.parse(feed.url), contents: body);
  }

  Future<void> _loadCachedArticle({required Feed feed}) async {
    final document = await Cache.readCachedFeed(feedsUri: Uri.parse(feed.url));

    if (document != null) {
      ref.read(currentArticlesProvider).clear();
      await loadCachedFeed(document: document, feed: feed);
      refreshArticlesProvider();
    }
  }

  Future<void> _loadCachedArticles({
    required List<Feed> feeds,
  }) async {
    ref.read(currentArticlesProvider).clear();

    for (var feed in feeds) {
      final cachedArticles =
          await Cache.readCachedFeed(feedsUri: Uri.parse(feed.url));

      if (cachedArticles != null) {
        await loadCachedFeed(
          document: cachedArticles,
          feed: feed,
        );
      }
    }
    refreshArticlesProvider();
  }

  Future<void> _loadFetchedArticle({required Feed feed}) async {
    final response = await http.get(Uri.parse(feed.url));

    if (response.statusCode == 200) {
      ref.read(currentArticlesProvider).clear();
      await _fetchFeed(
        feed: feed,
        body: response.body,
      );
      await _writeCachedFeeds(feed: feed, body: response.body);
      refreshArticlesProvider();
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<void> _loadFetchedArticles({
    required List<Feed> feeds,
  }) async {
    ref.read(currentArticlesProvider).clear();
    for (var feed in feeds) {
      final response = await http.get(Uri.parse(feed.url));

      if (response.statusCode == 200) {
        await _fetchFeed(
          feed: feed,
          body: response.body,
        );
        await _writeCachedFeeds(feed: feed, body: response.body);
      } else {
        throw Exception('Failed to load');
      }
    }
    refreshArticlesProvider();
  }

  Future<bool> _loadArticles({
    required LoadType loadType,
    required Future<void> Function(Feed feed) getFeed,
    required Future<void> Function(List<Feed> feeds) getFeeds,
  }) async {
    final feed = ref.read(selectedFeedProvider);
    final feeds = ref.read(feedsProvider);

    if (feed != null) {
      await getFeed(feed);
    } else {
      if (feeds.isEmpty) {
        return false;
      }

      await getFeeds(feeds);
    }

    await _setAllArticles(feeds: feeds);

    ref.read(isRefreshingProvider.notifier).state = false;
    ref.read(hasReadProvider.notifier).refresh();

    return true;
  }

  Future<void> _setAllArticles({required List<Feed> feeds}) async {
    ref.read(allArticlesProvider).clear();

    for (final feed in feeds) {
      final cachedArticles =
          await Cache.readCachedFeed(feedsUri: Uri.parse(feed.url));

      if (cachedArticles != null) {
        await loadCachedFeed(
          document: cachedArticles,
          feed: feed,
          allArticles: true,
        );
      }
    }
  }

  Future<bool> loadCachedAndFetchedArticles() {
    return _loadArticles(
      loadType: LoadType.cachedAndOnline,
      getFeed: (feed) async {
        await _loadCachedArticle(feed: feed);
        await _loadFetchedArticle(feed: feed);
      },
      getFeeds: (feeds) async {
        await _loadCachedArticles(feeds: feeds);
        await _loadFetchedArticles(feeds: feeds);
      },
    );
  }

  Future<bool> loadFetchedArticles() {
    return _loadArticles(
      loadType: LoadType.online,
      getFeed: (feed) => _loadFetchedArticle(feed: feed),
      getFeeds: (feeds) => _loadFetchedArticles(feeds: feeds),
    );
  }

  Future<bool> loadCachedArticles() {
    return _loadArticles(
      loadType: LoadType.cached,
      getFeed: (feed) => _loadCachedArticle(feed: feed),
      getFeeds: (feeds) => _loadCachedArticles(feeds: feeds),
    );
  }
}

final loadArticlesProvider =
    NotifierProvider<LoadArticlesNotifier, Future<bool>>(() {
  return LoadArticlesNotifier();
});
