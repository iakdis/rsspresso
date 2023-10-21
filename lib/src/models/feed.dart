import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/articles_provider.dart';
import '../providers/has_read_provider.dart';

class Feed {
  const Feed({
    required this.url,
    this.author,
    this.favicon,
  });

  final String url;
  final String? author;
  final String? favicon;

  static int unreadAmount(WidgetRef ref,
      {String? url, bool dontCheckFeed = false}) {
    var amount = 0;

    final articles = ref.watch(allArticlesProvider);
    final hasReadMap = ref.watch(hasReadProvider.notifier);

    for (final article in articles) {
      final equalsFeed = url == article.feed.url;

      if (equalsFeed || dontCheckFeed) {
        final hasRead = hasReadMap.get(article.id);

        if (!hasRead) amount++;
      }
    }

    return amount;
  }

  factory Feed.fromJson(Map data) {
    final url = data['url'] as String;
    final author = data['author'] as String?;
    final favicon = data['favicon'] as String?;

    return Feed(
      url: url,
      author: author,
      favicon: favicon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'author': author,
      'favicon': favicon,
    };
  }
}

class FeedAlreadyExistsException implements Exception {}
