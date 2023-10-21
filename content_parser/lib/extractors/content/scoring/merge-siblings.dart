import 'package:universal_html/html.dart';

import '../../../utils/dom/constants.dart';
import '../../../utils/dom/link-density.dart';
import '../../../utils/text/has-sentence-end.dart';
import 'get-score.dart';

// Now that we have a top_candidate, look through the siblings of
// it to see if any of them are decently scored. If they are, they
// may be split parts of the content (Like two divs, a preamble and
// a body.) Example:
// http://articles.latimes.com/2009/oct/14/business/fi-bigtvs14
Element mergeSiblings(Element candidate, int topScore, DocumentFragment doc) {
  final parent = candidate.parent;
  if (parent == null) {
    return candidate;
  }

  final int siblingScoreThreshold = (topScore * 0.25).round();
  final Element wrappingDiv = Element.tag('div');

  for (var sibling in parent.children) {
    final Element $sibling = sibling;
    // Ignore tags like BR, HR, etc
    if (NON_TOP_CANDIDATE_TAGS_RE.hasMatch(sibling.localName.toLowerCase())) {
      continue;
    }

    final int? siblingScore = getScore($sibling);
    if (siblingScore != null) {
      if ($sibling == candidate) {
        wrappingDiv.append($sibling.clone(true));
      } else {
        int contentBonus = 0;
        final double density = linkDensity($sibling);

        // If sibling has a very low link density,
        // give it a small bonus
        if (density < 0.05) {
          contentBonus += 20;
        }

        // If sibling has a high link density,
        // give it a penalty
        if (density >= 0.5) {
          contentBonus -= 20;
        }

        // If sibling node has the same class as
        // candidate, give it a bonus
        if ($sibling.getAttribute('class') == candidate.getAttribute('class')) {
          contentBonus += (topScore * 0.2).round();
        }

        final int newScore = siblingScore + contentBonus;

        if (newScore >= siblingScoreThreshold) {
          continue;
        }
        if ($sibling.localName.toLowerCase() == 'p') {
          final String siblingContent = $sibling.text!.trim();
          final int siblingContentLength = textLength(siblingContent);

          if (siblingContentLength > 80 && density < 0.25) {
            continue;
          }
          if (siblingContentLength <= 80 &&
              density == 0 &&
              hasSentenceEnd(siblingContent)) {
            continue;
          }
        }
      }
    }
  }

  if (wrappingDiv.children.length == 1 &&
      wrappingDiv.children.first == candidate) {
    return candidate;
  }

  return wrappingDiv;
}
