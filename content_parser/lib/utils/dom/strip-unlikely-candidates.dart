// Assuming you have defined CANDIDATES_WHITELIST and CANDIDATES_BLACKLIST as RegExp constants.

import 'package:universal_html/html.dart';

import 'constants.dart';

DocumentFragment stripUnlikelyCandidates(DocumentFragment document) {
  // Loop through the provided document and remove any non-link nodes
  // that are unlikely candidates for article content.
  //
  // Links are ignored because there are very often links to content
  // that are identified as non-body-content, but may be inside
  // article-like content.

  final nodes = document.querySelectorAll('*');
  for (final node in nodes) {
    final element = node;
    if (element.tagName.toLowerCase() == 'a') continue;

    final classes = element.attributes['class'] ?? '';
    final id = element.attributes['id'] ?? '';
    final classAndId = '$classes $id';

    if (CANDIDATES_WHITELIST.hasMatch(classAndId)) {
      continue;
    }
    if (CANDIDATES_BLACKLIST.hasMatch(classAndId)) {
      element.remove();
    }
  }

  return document;
}
