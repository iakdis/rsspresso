// Import other necessary dependencies here

// Rewrite the tag name to div if it's a top-level node like body or
// html to avoid later complications with multiple body tags.

import 'package:universal_html/html.dart';

import 'convert-node-to.dart';

DocumentFragment rewriteTopLevel(Element article, DocumentFragment document) {
  // I'm not using context here because
  // it's problematic when converting the
  // top-level/root node - AP
  document =
      convertNodeTo(document.querySelector('html'), document, tag: 'div');
  document =
      convertNodeTo(document.querySelector('body'), document, tag: 'div');

  return document;
}
