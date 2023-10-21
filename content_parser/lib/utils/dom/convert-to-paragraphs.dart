// Function to convert <div> tags without block level elements inside of them to <p> tags.
import 'package:universal_html/html.dart';

import 'brs-to-ps.dart';
import 'constants.dart';
import 'convert-node-to.dart';

DocumentFragment convertDivs(DocumentFragment doc) {
  final List<Element> divElements = doc.querySelectorAll('div');

  for (final div in divElements) {
    final $div = div;
    final convertible = $div.querySelectorAll(DIV_TO_P_BLOCK_TAGS).isEmpty;

    if (convertible) {
      convertNodeTo($div, doc, tag: 'p');
    }
  }

  return doc;
}

// Function to convert <span> tags that are not children of <p> or <div> tags to <p> tags.
DocumentFragment convertSpans(DocumentFragment doc) {
  final List<Element> spanElements = doc.querySelectorAll('span');

  for (final span in spanElements) {
    final spanElement = span;
    final convertible = !getAncestors(spanElement).any((ancestor) => [
          'p',
          'div',
          'li',
          'figcaption'
        ].contains(ancestor.tagName.toLowerCase()));

    if (!convertible) {
      convertNodeTo(spanElement, doc, tag: 'p');
    }
  }

  return doc;
}

// Function to get all the ancestors (parent elements) of an element.
List<Element> getAncestors(Element element) {
  final List<Element> ancestors = [];
  Element? parent = element.parent;

  while (parent != null) {
    ancestors.add(parent);
    parent = parent.parent;
  }

  return ancestors;
}

// Loop through the provided doc and convert any p-like elements to actual paragraph tags.
DocumentFragment convertToParagraphs(DocumentFragment doc) {
  doc = brsToPs(doc);
  doc = convertDivs(doc);
  doc = convertSpans(doc);

  return doc;
}
