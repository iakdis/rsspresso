import 'package:content_parser/extractors/content/scoring/score-paragraph.dart';
import 'package:universal_html/html.dart';

import '../../../utils/dom/constants.dart';

// Score an individual node. Has some smarts for paragraphs, otherwise
// just scores based on tag.

int scoreNode(Element node) {
  final String tagName = node.localName.toLowerCase();

  // TODO: Consider ordering by most likely.
  // E.g., if divs are a more common tag on a page,
  // Could save doing that regex test on every node – AP
  if (PARAGRAPH_SCORE_TAGS.hasMatch(tagName)) {
    return scoreParagraph(node);
  }
  if (tagName == 'div') {
    return 5;
  }
  if (CHILD_CONTENT_TAGS.hasMatch(tagName)) {
    return 3;
  }
  if (BAD_TAGS.hasMatch(tagName)) {
    return -3;
  }
  if (tagName == 'th') {
    return -5;
  }

  return 0;
}
