import 'package:universal_html/html.dart';

// strips all tags from a string of text
String stripTags(String text, DocumentFragment document) {
  // Wrapping text in html element prevents errors when text
  // has no html
  final cleanText = Element.html('<span>$text</span>').text;
  return cleanText == null || cleanText.isEmpty ? text : cleanText;
}
