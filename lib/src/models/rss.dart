import 'package:dart_rss/dart_rss.dart';
import 'package:dart_rss/domain/rss1_feed.dart';
import 'package:xml/xml.dart';

enum FeedType {
  rss1,
  rss2,
  atom,
}

class GeneralFeed {
  final String? title;
  final List<GeneralItem> items;

  const GeneralFeed({
    this.title,
    this.items = const [],
  });

  static FeedType _parseFeedType(String xml) {
    final FeedType feedType;

    final isRss =
        XmlDocument.parse(xml).document?.findAllElements('rss').isNotEmpty;
    final isAtom =
        XmlDocument.parse(xml).document?.findAllElements('feed').isNotEmpty;

    if (isRss == true) {
      // RSS version 1.0 or 2.0
      final version = XmlDocument.parse(xml)
          .document
          ?.findAllElements('rss')
          .first
          .getAttribute('version');
      feedType = version == '1.0' ? FeedType.rss1 : FeedType.rss2;
    } else if (isAtom == true) {
      // Atom
      feedType = FeedType.atom;
    } else {
      // Default: RSS 2.0
      feedType = FeedType.rss2;
    }

    return feedType;
  }

  factory GeneralFeed.parse(String xml) {
    final String? title;
    final List<GeneralItem> items;

    switch (_parseFeedType(xml)) {
      case FeedType.rss1:
        final feed = Rss1Feed.parse(xml);
        title = feed.title;
        items = feed.items
            .map((e) => GeneralItem(
                  title: e.title,
                  description: e.description,
                  link: e.link,
                  pubDate: null,
                  content: e.content?.value,
                ))
            .toList();
        break;
      case FeedType.rss2:
        final feed = RssFeed.parse(xml);
        title = feed.title;
        items = feed.items
            .map((e) => GeneralItem(
                  title: e.title,
                  description: e.description,
                  link: e.link,
                  pubDate: e.pubDate,
                  content: e.content?.value,
                ))
            .toList();
        break;
      case FeedType.atom:
        final feed = AtomFeed.parse(xml);
        title = feed.title;
        items = feed.items
            .map((e) => GeneralItem(
                  title: e.title,
                  description: e.summary,
                  link: e.links.isEmpty
                      ? null
                      : e.links.where((e) => e.rel == 'alternate').isNotEmpty
                          ? e.links.firstWhere((e) => e.rel == 'alternate').href
                          : e.links.first.href,
                  pubDate: e.published,
                  content: e.content,
                ))
            .toList();
        break;
    }

    return GeneralFeed(
      title: title,
      items: items,
    );
  }
}

class GeneralItem {
  final String? title;
  final String? description;
  final String? link;
  final String? pubDate;
  final String? content;

  const GeneralItem({
    required this.title,
    required this.description,
    required this.link,
    required this.pubDate,
    required this.content,
  });
}
