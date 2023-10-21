// Function to get the score of a node based on the node's score attribute.
// Returns null if no score is set.
import 'package:universal_html/html.dart';

int? getScore(Element node) {
  final String? scoreAttr = node.getAttribute('score');

  if (scoreAttr != null) {
    return int.tryParse(scoreAttr);
  }

  return null;
}
