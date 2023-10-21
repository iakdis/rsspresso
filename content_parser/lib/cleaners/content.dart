// Import other necessary dependencies here

// Clean our article content, returning a new, cleaned node.
import 'package:universal_html/html.dart';

import '../utils/dom/clean-attributes.dart';
import '../utils/dom/clean-h-ones.dart';
import '../utils/dom/clean-headers.dart';
import '../utils/dom/clean-images.dart';
import '../utils/dom/clean-tags.dart';
import '../utils/dom/make-links-absolute.dart';
import '../utils/dom/remove-empty.dart';
import '../utils/dom/rewrite-top-level.dart';
import '../utils/dom/strip-junk-tags.dart';

Element extractCleanNode({
  required Element article,
  required DocumentFragment document,
  bool cleanConditionally = true,
  String? title,
  String? url,
  bool defaultCleaner = true,
}) {
  // Rewrite the tag name to div if it's a top-level node like body or
  // html to avoid later complications with multiple body tags.
  rewriteTopLevel(article, document);

  // Drop small images and spacer images
  // Only do this if defaultCleaner is set to true;
  // this can sometimes be too aggressive.
  if (defaultCleaner) cleanImages(article, document);

  // Make links absolute
  makeLinksAbsolute(article, document, url);

  // Mark elements to keep that would normally be removed.
  // E.g., stripJunkTags will remove iframes, so we're going to mark
  // YouTube/Vimeo videos as elements we want to keep.
  // markToKeep(article, document, url);

  // Drop certain tags like <title>, etc
  // This is mostly for cleanliness, not security.
  stripJunkTags(article);

  // H1 tags are typically the article title, which should be extracted
  // by the title extractor instead. If there's less than 3 of them (<3),
  // strip them. Otherwise, turn 'em into H2s.
  cleanHOnes(article, document);

  // Clean headers
  cleanHeaders(article, document, title);

  // We used to clean UL's and OL's here, but it was leading to
  // too many in-article lists being removed. Consider a better
  // way to detect menus particularly and remove them.
  // Also optionally running, since it can be overly aggressive.
  if (defaultCleaner) cleanTags(article, document);

  // Remove empty paragraph nodes
  removeEmpty(article, document);

  // Remove unnecessary attributes
  cleanAttributes(article, document);

  return article;
}
