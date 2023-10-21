// Get the score of a node based on its className and id.
import 'package:universal_html/html.dart';

import '../../../utils/dom/constants.dart';

int getWeight(Element node) {
  final String? classes = node.getAttribute('class');
  final String? id = node.getAttribute('id');
  int score = 0;

  if (id != null) {
    // if id exists, try to score on both positive and negative
    if (POSITIVE_SCORE_RE.hasMatch(id)) {
      score += 25;
    }
    if (NEGATIVE_SCORE_RE.hasMatch(id)) {
      score -= 25;
    }
  }

  if (classes != null) {
    if (score == 0) {
      // if classes exist and id did not contribute to score
      // try to score on both positive and negative
      if (POSITIVE_SCORE_RE.hasMatch(classes)) {
        score += 25;
      }
      if (NEGATIVE_SCORE_RE.hasMatch(classes)) {
        score -= 25;
      }
    }

    // even if score has been set by id, add score for
    // possible photo matches
    // "try to keep photos if we can"
    if (PHOTO_HINTS_RE.hasMatch(classes)) {
      score += 10;
    }

    // add 25 if class matches entry-content-asset,
    // a class apparently instructed for use in the
    // Readability publisher guidelines
    // https://www.readability.com/developers/guidelines
    if (READABILITY_ASSET.hasMatch(classes)) {
      score += 25;
    }
  }

  return score;
}
