import 'package:universal_html/html.dart';

import './constants.dart';

DocumentFragment cleanForHeight(Element img, DocumentFragment doc) {
  final int? height = int.tryParse(img.getAttribute('height') ?? '');
  final int width = int.tryParse(img.getAttribute('width') ?? '') ?? 20;

  // Remove images that explicitly have very small heights or
  // widths because they are most likely shims or icons,
  // which aren't very useful for reading.
  if ((height ?? 20) < 10 || width < 10) {
    img.remove();
  } else if (height != null) {
    // Don't ever specify a height on images, so that we can
    // scale with respect to width without screwing up the
    // aspect ratio.
    img.attributes.remove('height');
  }

  return doc;
}

// Cleans out images where the source string matches transparent/spacer/etc
// TODO This seems very aggressive - AP
DocumentFragment removeSpacers(Element img, DocumentFragment doc) {
  if (SPACER_RE.hasMatch(img.getAttribute('src') ?? '')) {
    img.remove();
  }

  return doc;
}

DocumentFragment cleanImages(Element article, DocumentFragment doc) {
  article.querySelectorAll('img').forEach((img) {
    cleanForHeight(img, doc);
    removeSpacers(img, doc);
  });

  return doc;
}
