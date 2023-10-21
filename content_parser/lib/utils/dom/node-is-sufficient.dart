// Given a node, determine if it's article-like enough to return
// param: node (a cheerio node)
// return: boolean

import 'package:universal_html/html.dart';

bool nodeIsSufficient(Element node) {
  return (node.text?.trim().length ?? 0) >= 100;
}
