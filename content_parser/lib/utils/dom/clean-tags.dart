import 'package:universal_html/html.dart';

import '../../extractors/content/scoring/get-or-init-score.dart';
import '../../extractors/content/scoring/get-score.dart';
import '../../extractors/content/scoring/score-commas.dart';
import '../../extractors/content/scoring/set-score.dart';
import '../text/normalize-spaces.dart';
import 'constants.dart';
import 'link-density.dart';

void removeUnlessContent(
    Element element, DocumentFragment document, int weight) {
  // Explicitly save entry-content-asset tags, which are
  // noted as valuable in the Publisher guidelines. For now
  // this works everywhere. We may want to consider making
  // this less of a sure-thing later.
  if (element.classes.contains('entry-content-asset')) {
    return;
  }

  final content = normalizeSpaces(element.text ?? '');

  if (scoreCommas(content) < 10) {
    final pCount = element.querySelectorAll('p').length;
    final inputCount = element.querySelectorAll('input').length;

    // Looks like a form, too many inputs.
    if (inputCount > pCount ~/ 3) {
      element.remove();
      return;
    }

    final contentLength = content.length;
    final imgCount = element.querySelectorAll('img').length;

    // Content is too short, and there are no images, so
    // this is probably junk content
    if (contentLength < 25 && imgCount == 0) {
      element.remove();
      return;
    }

    final density = linkDensity(element);

    // Too high of link density, is probably a menu or
    // something similar.
    // console.log(weight, density, contentLength)
    if (weight < 25 && density > 0.2 && contentLength > 75) {
      element.remove();
      return;
    }

    // Too high of a link density, despite the score being
    // high.
    if (weight >= 25 && density > 0.5) {
      // Don't remove the node if it's a list and the
      // previous sibling starts with a colon though. That
      // means it's probably content.
      final tagName = element.localName;
      final nodeIsList = tagName == 'ol' || tagName == 'ul';
      if (nodeIsList) {
        final previousNode = element.previousElementSibling;
        if (previousNode != null &&
            normalizeSpaces(previousNode.text ?? '').endsWith(':')) {
          return;
        }
      }

      element.remove();
      return;
    }

    final scriptCount = element.querySelectorAll('script').length;

    if (scriptCount > 0 && contentLength < 150) {
      element.remove();
    }
  }
}

// Given an article, clean it of some superfluous content specified by
// tags. Things like forms, ads, etc.
//
// Tags is an array of tag name's to search through. (like div, form,
// etc)
//
// Return this same doc.
DocumentFragment cleanTags(Element article, DocumentFragment document) {
  for (var node in article.querySelectorAll(CLEAN_CONDITIONALLY_TAGS)) {
    // If marked to keep, skip it
    if (node.classes.contains(KEEP_CLASS) ||
        node.querySelector('.$KEEP_CLASS') != null) {
      continue;
    }

    var weight = getScore(node);
    if (weight == null) {
      weight = getOrInitScore(node, document);
      setScore(node, weight);
    }

    // drop node if its weight is < 0
    if (weight < 0) {
      node.remove();
    } else {
      // determine if node seems like content
      removeUnlessContent(node, document, weight);
    }
  }

  return document;
}
