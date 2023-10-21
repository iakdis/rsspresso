// Adds 1/4 of a child's score to its parent.
import 'package:universal_html/html.dart';

import 'add-score.dart';

Element addToParent(Element node, DocumentFragment doc, int score) {
  final Element? parent = node.parent;
  if (parent != null) {
    addScore(parent, doc, (score * 0.25).round());
  }

  return node;
}
