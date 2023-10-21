import 'package:universal_html/html.dart';

// Determines the length of text (ignoring leading and trailing whitespaces)
// and replaces consecutive whitespaces with a single space.

int textLength(String text) {
  return text.trim().replaceAll(RegExp(r'\s+'), ' ').length;
}

// Determines what percentage of the text in a node is link text.
// Takes a node (Element) as input and returns a double.
double linkDensity(Element node) {
  final int totalTextLength = textLength(node.text!.trim());

  final String linkText = node.querySelectorAll('a').map((e) => e.text!).join();
  final int linkLength = textLength(linkText);

  if (totalTextLength > 0) {
    return linkLength / totalTextLength;
  }
  if (totalTextLength == 0 && linkLength > 0) {
    return 1;
  }

  return 0;
}
