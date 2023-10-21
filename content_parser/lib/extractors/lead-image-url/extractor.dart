import 'package:content_parser/extractors/content/extractor.dart';
import 'package:universal_html/html.dart';

import '../../cleaners/lead-image-url.dart';
import '../../utils/dom/extract-from-meta.dart';
import 'constants.dart';
import 'score-images.dart';

/// Given a resource, try to find the lead image URL from within
/// it. Like content and next page extraction, uses a scoring system
/// to determine what the most likely image may be. Short circuits
/// on really probable things like og:image meta tags.
///
/// Potential signals to still take advantage of:
///   * domain
///   * weird aspect ratio
class GenericLeadImageUrlExtractor {
  String? extract(String html, {required String url}) {
    String? cleanUrl;

    final document = DocumentFragment.html(html);

    // Check to see if we have a matching meta tag that we can make use of.
    // Moving this higher because common practice is now to use large
    // images on things like Open Graph or Twitter cards.
    // images usually have for things like Open Graph.
    final imageUrl = extractFromMeta(
      document,
      LEAD_IMAGE_URL_META_TAGS,
      [],
      cleanTags: false,
    );

    if (imageUrl != null) {
      cleanUrl = cleanImage(imageUrl);

      if (cleanUrl != null) return cleanUrl;
    }

    // Next, try to find the "best" image via the content.
    // We'd rather not have to fetch each image and check dimensions,
    // so try to do some analysis and determine them instead.
    final content = GenericContentExtractor()
        .extractAsElement(html, title: 'title', url: url);
    final imgs = content.querySelectorAll('img');
    final imgScores = <String, int>{};

    for (var index = 0; index < imgs.length; index++) {
      final img = imgs[index];
      final src = img.getAttribute('src');

      if (src == null) continue;

      var score = scoreImageUrl(src);
      score += scoreAttr(img);
      score += scoreByParents(img);
      score += scoreBySibling(img);
      score += scoreByDimensions(img);
      score += scoreByPosition(imgs, index);

      imgScores.addEntries([MapEntry(src, score)]);
    }

    final topScoreEntry = imgScores.entries.reduce(
      (acc, entry) => entry.value > acc.value ? entry : acc,
    );

    if (topScoreEntry.value > 0) {
      cleanUrl = cleanImage(topScoreEntry.key);

      if (cleanUrl != null) return cleanUrl;
    }

    // If nothing else worked, check to see if there are any really
    // probable nodes in the doc, like <link rel="image_src" />.
    for (final selector in LEAD_IMAGE_URL_SELECTORS) {
      final node = document.querySelector(selector);
      final src = node?.getAttribute('src');
      if (src != null) {
        cleanUrl = cleanImage(src);
        if (cleanUrl != null) return cleanUrl;
      }

      final href = node?.getAttribute('href');
      if (href != null) {
        cleanUrl = cleanImage(href);
        if (cleanUrl != null) return cleanUrl;
      }

      final value = node?.getAttribute('value');
      if (value != null) {
        cleanUrl = cleanImage(value);
        if (cleanUrl != null) return cleanUrl;
      }
    }

    return null;
  }
}
