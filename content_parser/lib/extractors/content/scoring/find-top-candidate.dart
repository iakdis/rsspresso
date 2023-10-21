import 'package:universal_html/html.dart';

import '../../../utils/dom/constants.dart';
import './merge-siblings.dart' show mergeSiblings;
import 'get-score.dart';

// After we've calculated scores, loop through all of the possible
// candidate nodes we found and find the one with the highest score.
Element findTopCandidate(DocumentFragment doc) {
  Element? candidate;
  int topScore = 0;

  doc.querySelectorAll('[score]').forEach((node) {
    // Ignore tags like BR, HR, etc
    if (NON_TOP_CANDIDATE_TAGS_RE.hasMatch(node.tagName.toLowerCase())) {
      return;
    }

    final Element $node = node;
    final int score = getScore($node) ?? 0;

    if (score > topScore) {
      topScore = score;
      candidate = $node;
    }
  });

  // If we don't have a candidate, return the body
  // or whatever the first element is
  if (candidate == null) {
    return doc.querySelector('body')!;
  }

  candidate = mergeSiblings(candidate!, topScore, doc);

  return candidate!;
}
