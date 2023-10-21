import 'package:universal_html/html.dart';

import '../../extractors/content/scoring/get-weight.dart';
import '../text/normalize-spaces.dart';
import 'constants.dart';

Node cleanHeaders(Element article, DocumentFragment document, String? title) {
  final headers = article.querySelectorAll(HEADER_TAG_LIST);

  for (var header in headers) {
    final headerElement = Element.tag(header.tagName.toLowerCase());

    // Remove any headers that appear before all other p tags in the
    // document. This probably means that it was part of the title, a
    // subtitle or something else extraneous like a datestamp or byline,
    // all of which should be handled by other metadata handling.
    if (headerElement.parent?.previousElementSibling?.tagName.toLowerCase() ==
        'p') {
      headerElement.remove();
      continue;
    }

    // Remove any headers that match the title exactly.
    if (normalizeSpaces(headerElement.text ?? '') == title) {
      headerElement.remove();
      continue;
    }

    // If this header has a negative weight, it's probably junk.
    // Get rid of it.
    if (getWeight(headerElement) < 0) {
      headerElement.remove();
      continue;
    }

    return headerElement;
  }

  return document;
}
