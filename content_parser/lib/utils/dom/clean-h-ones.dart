import 'package:universal_html/html.dart';

import 'convert-node-to.dart';

void cleanHOnes(Element article, DocumentFragment document) {
  final hOnes = article.querySelectorAll('h1');

  if (hOnes.length < 3) {
    for (var node in hOnes) {
      node.remove();
    }
  } else {
    for (var node in hOnes) {
      convertNodeTo(node, document, tag: 'h2');
    }
  }
}
