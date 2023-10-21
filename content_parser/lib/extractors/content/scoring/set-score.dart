// Function to set the score attribute of a node.
import 'package:universal_html/html.dart';

Element setScore(Element node, int score) {
  node.setAttribute('score', score.toString());
  return node;
}
