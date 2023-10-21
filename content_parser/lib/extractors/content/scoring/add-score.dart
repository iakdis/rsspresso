// Function to add score to the node and update its score.
import 'package:universal_html/html.dart';

import 'get-or-init-score.dart';
import 'set-score.dart';

Element addScore(Element node, DocumentFragment doc, int amount) {
  try {
    int score = getOrInitScore(node, doc) + amount;
    setScore(node, score);
  } catch (e) {
    // Ignoring; error occurs in scoreNode
  }

  return node;
}
