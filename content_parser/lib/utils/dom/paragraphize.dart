// Given a node, turn it into a P if it is not already a P, and
// make sure it conforms to the constraints of a P tag (I.E. does
// not contain any other block tags.)
//
// If the node is a <br />, it treats the following inline siblings
// as if they were its children.
//
// :param node: The node to paragraphize; this is a raw node
// :param doc: The DocumentFragment object to handle dom manipulation
// :param br: Whether or not the passed node is a br

import 'package:universal_html/html.dart';

import 'constants.dart';

DocumentFragment paragraphize(Element node, DocumentFragment doc,
    {bool br = false}) {
  final element = node;

  if (br) {
    var sibling = node.nextNode;
    final p = Element.tag('p');

    // while the next node is text or not a block level element
    // append it to a new p node
    while (sibling != null &&
        !(sibling is Element &&
            BLOCK_LEVEL_TAGS_RE.hasMatch(sibling.tagName.toLowerCase()))) {
      final nextSibling = sibling.nextNode;
      p.append(sibling);
      sibling = nextSibling;
    }

    element.replaceWith(p);
    element.remove();
    return doc;
  }

  return doc;
}
