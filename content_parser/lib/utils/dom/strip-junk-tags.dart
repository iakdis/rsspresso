import 'package:universal_html/html.dart';

import 'constants.dart';

Element stripJunkTags(Element article, {List<String> tags = const []}) {
  if (tags.isEmpty) {
    tags = STRIP_OUTPUT_TAGS;
  }

  // Remove matching elements, but ignore
  // any element with a class of mercury-parser-keep
  for (var tag in tags) {
    article.querySelectorAll(tag).forEach((element) {
      if (!element.classes.contains(KEEP_CLASS)) {
        element.remove();
      }
    });
  }

  return article;
}
