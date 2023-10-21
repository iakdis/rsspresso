import 'package:universal_html/html.dart';

DocumentFragment removeEmpty(Element article, DocumentFragment document) {
  for (var p in article.querySelectorAll('p')) {
    if (p.querySelectorAll('iframe, img').isEmpty &&
        p.text?.trim().isEmpty == true) {
      p.remove();
    }
  }

  return document;
}
