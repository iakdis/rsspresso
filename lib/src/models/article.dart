import 'dart:collection';

import 'feed.dart';

final class Article extends LinkedListEntry<Article> {
  Article({
    required this.title,
    required this.author,
    required this.link,
    required this.date,
    required this.textContent,
    required this.htmlContent,
    required this.favicon,
    required this.feed,
  });

  final String title;
  final String author;
  final String link;
  final DateTime date;
  final String textContent;
  final String htmlContent;
  final String favicon;
  final Feed feed;

  String get id => '${link}_$title';

  factory Article.copyWith({required Article article}) => Article(
        title: article.title,
        author: article.author,
        link: article.link,
        date: article.date,
        textContent: article.textContent,
        htmlContent: article.htmlContent,
        favicon: article.favicon,
        feed: article.feed,
      );
}
