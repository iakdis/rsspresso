import 'package:content_parser/utils/dom/paragraphize.dart';
import 'package:universal_html/html.dart';

// ## NOTES:
// Another good candidate for refactoring/optimizing.
// Very imperative code, I don't love it. - AP

// Given a cheerio object, convert consecutive <br /> tags into
// <p /> tags instead.
//
// :param doc: The DocumentFragment object representing the cheerio object

DocumentFragment brsToPs(DocumentFragment doc) {
  bool collapsing = false;
  final List<Element> brElements = doc.querySelectorAll('br');

  for (final element in brElements) {
    final nextElement = element.nextElementSibling;

    if (nextElement != null && nextElement.tagName.toLowerCase() == 'br') {
      collapsing = true;
      element.remove();
    } else if (collapsing) {
      collapsing = false;
      paragraphize(element, doc, br: true);
    }
  }

  return doc;
}
