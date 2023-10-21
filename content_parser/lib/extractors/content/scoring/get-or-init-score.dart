// Function to get and return the score if it exists.
// If not, initializes a score based on the node's tag type.
import 'package:universal_html/html.dart';

import 'add-to-parent.dart';
import 'get-score.dart';
import 'get-weight.dart';
import 'score-node.dart';

int getOrInitScore(Element node, DocumentFragment doc,
    [bool weightNodes = true]) {
  var score = getScore(node);

  if (score != null) {
    return score;
  }

  score = scoreNode(node);

  if (weightNodes) {
    score += getWeight(node);
  }

  addToParent(node, doc, score);

  return score;
}
