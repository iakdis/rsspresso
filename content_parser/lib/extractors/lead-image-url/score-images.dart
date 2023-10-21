import 'package:universal_html/html.dart';

import '../../utils/dom/constants.dart';
import 'constants.dart';

String getSig(Element node) {
  return '${node.attributes['class'] ?? ''} ${node.attributes['id'] ?? ''}';
}

// Scores image urls based on a variety of heuristics.
int scoreImageUrl(String url) {
  url = url.trim();
  int score = 0;

  if (POSITIVE_LEAD_IMAGE_URL_HINTS_RE.hasMatch(url)) {
    score += 20;
  }

  if (NEGATIVE_LEAD_IMAGE_URL_HINTS_RE.hasMatch(url)) {
    score -= 20;
  }

  // TODO: We might want to consider removing this as
  // gifs are much more common/popular than they once were
  if (GIF_RE.hasMatch(url)) {
    score -= 10;
  }

  if (JPG_RE.hasMatch(url)) {
    score += 10;
  }

  // PNGs are neutral.

  return score;
}

// Alt attribute usually means non-presentational image.
int scoreAttr(Element img) {
  if (img.attributes.containsKey('alt')) {
    return 5;
  }

  return 0;
}

// Look through our parent and grandparent for figure-like
// container elements, give a bonus if we find them
int scoreByParents(Element img) {
  int score = 0;
  final figParent = findClosestParentFigure(img);

  if (figParent != null) {
    score += 25;
  }

  final parent = img.parent;
  Element? gParent;
  if (parent != null) {
    gParent = parent.parent;
  }

  for (var node in [parent, gParent]) {
    if (node != null && PHOTO_HINTS_RE.hasMatch(getSig(node))) {
      score += 15;
    }
  }

  return score;
}

Element? findClosestParentFigure(Element element) {
  var parent = element.parent;

  while (parent != null && parent.tagName.toLowerCase() != 'figure') {
    parent = parent.parent;
  }

  return parent;
}

// Look at our immediate sibling and see if it looks like it's a
// caption. Bonus if so.
int scoreBySibling(Element img) {
  int score = 0;
  final sibling = img.nextElementSibling;
  final siblingTag = sibling?.tagName.toLowerCase();

  if (sibling != null && siblingTag == 'figcaption') {
    score += 25;
  }

  if (sibling != null && PHOTO_HINTS_RE.hasMatch(getSig(sibling))) {
    score += 15;
  }

  return score;
}

int scoreByDimensions(Element img) {
  int score = 0;

  final width = double.tryParse(img.attributes['width'] ?? '');
  final height = double.tryParse(img.attributes['height'] ?? '');
  final src = img.attributes['src'];

  // Penalty for skinny images
  if (width != null && width <= 50) {
    score -= 50;
  }

  // Penalty for short images
  if (height != null && height <= 50) {
    score -= 50;
  }

  if (width != null && height != null && src?.contains('sprite') == true) {
    final area = width * height;
    if (area < 5000) {
      // Smaller than 50 x 100
      score -= 100;
    } else {
      score += (area / 1000).round();
    }
  }

  return score;
}

int scoreByPosition(List<Element> imgs, int index) {
  return imgs.length ~/ 2 - index;
}
