// Function to convert spans to divs.
import 'package:content_parser/extractors/content/scoring/score-node.dart';
import 'package:universal_html/html.dart';

import '../../../utils/dom/constants.dart';
import '../../../utils/dom/convert-node-to.dart';
import 'add-score.dart';
import 'get-or-init-score.dart';
import 'set-score.dart';

void convertSpans(Element node, DocumentFragment doc) {
  final String tagName = node.localName.toLowerCase();

  if (tagName == 'span') {
    // Convert spans to divs
    convertNodeTo(node, doc, tag: 'div');
  }
}

// Function to add scores to the node and its ancestors.
void addScoreTo(Element node, DocumentFragment doc, int score) {
  convertSpans(node, doc);
  addScore(node, doc, score);
}

// Function to score paragraphs and pre tags, adding scores to nodes and ancestors.
DocumentFragment scorePs(DocumentFragment doc, bool weightNodes) {
  doc.querySelectorAll('p, pre').forEach((node) {
    final nodeElement = node;
    setScore(nodeElement, getOrInitScore(nodeElement, doc, weightNodes));
    final parentElement = nodeElement.parent;
    final rawScore = scoreNode(nodeElement);

    if (parentElement != null) {
      addScoreTo(parentElement, doc, rawScore);
      if (parentElement.parent != null) {
        addScoreTo(parentElement.parent!, doc, rawScore ~/ 2);
      }
    }
  });

  return doc;
}

// Score content. Parents get the full value of their children's content score, grandparents half.
DocumentFragment scoreContent(DocumentFragment doc, [bool weightNodes = true]) {
  // First, look for special hNews based selectors and give them a big boost, if they exist.
  for (var selectorPair in HNEWS_CONTENT_SELECTORS) {
    final String parentSelector = selectorPair[0];
    final String childSelector = selectorPair[1];

    doc.querySelectorAll('$parentSelector $childSelector').forEach((node) {
      final parent = node.parent?.querySelector(parentSelector);
      if (parent != null) {
        addScore(parent, doc, 80);
      }
    });
  }

  // Doubling this again. Previous solution caused a bug in which parents weren't retaining scores.
  // This is not ideal, and should be fixed.
  scorePs(doc, weightNodes);
  scorePs(doc, weightNodes);

  return doc;
}
