// Import other necessary dependencies here

import 'package:universal_html/html.dart';

// import 'get-attrs.dart';

DocumentFragment convertNodeTo(Element? node, DocumentFragment document,
    {String tag = 'p'}) {
  if (node == null) return document;
  // final attrs = getAttrs(node) ?? {};
  final attrs = node.attributes;

  final attribString = attrs.keys
      .map((key) => '$key="${attrs[key]}"')
      .join(' '); // Interpolating attributes

  String? html;

  html = node.tagName.toLowerCase() == 'noscript' ? node.text : node.outerHtml;

  // if (document.browser != null) {
  //   // In the browser, the contents of noscript tags aren't rendered, therefore
  //   // transforms on the noscript tag (commonly used for lazy-loading) don't work
  //   // as expected. This test case handles that
  //   html = node.tagName.toLowerCase() == 'noscript' ? document(node).text() : document(node).html();
  // } else {
  //   html = document(node).contents();
  // }

  final newNode = DocumentFragment.html(
      '<$tag $attribString>$html</$tag>'); // New way of creating HTML element in Dart
  node.replaceWith(newNode);

  return document;
}
