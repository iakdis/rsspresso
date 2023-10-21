import 'package:universal_html/html.dart';

import 'constants.dart';

Element removeAllButWhitelist(Element article, DocumentFragment doc) {
  for (var node in article.querySelectorAll('*')) {
    var attrs = node.attributes;

    final whitelistAttrs = <String, String>{};
    attrs.forEach((attr, value) {
      if (WHITELIST_ATTRS_RE.hasMatch(attr)) {
        whitelistAttrs[attr] = value;
      }
    });
    for (var key in whitelistAttrs.keys) {
      node.attributes[key] = whitelistAttrs[key]!;
    }
  }

  // Remove the mercury-parser-keep class from the result
  article.querySelectorAll('.$KEEP_CLASS').forEach((node) {
    node.classes.remove(KEEP_CLASS);
  });

  return article;
}

// Remove attributes like style or align
Element cleanAttributes(Element article, DocumentFragment doc) {
  // Grabbing the parent because at this point
  // $article will be wrapped in a div which will
  // have a score set on it.
  var parent = article.parent;
  return removeAllButWhitelist(parent ?? article, doc);
}
