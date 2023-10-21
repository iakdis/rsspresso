import 'package:content_parser/utils/dom/strip-tags.dart';
import 'package:universal_html/html.dart';

String? extractFromMeta(
    DocumentFragment document, List<String> metaNames, List<String> cachedNames,
    {bool cleanTags = true}) {
  final foundNames =
      metaNames.where((name) => cachedNames.contains(name)).toList();

  for (final name in foundNames) {
    const type = 'name';
    const value = 'value';

    final nodes = document.querySelectorAll('meta[$type="$name"]');

    // Get the unique value of every matching node, in case there
    // are two meta tags with the same name and value.
    // Remove empty values.
    final values = nodes
        .map((node) => node.attributes[value])
        .where((text) => text != null && text.isNotEmpty)
        .toList();

    // If we have more than one value for the same name, we have a
    // conflict and can't trust any of them. Skip this name. If we have
    // zero, that means our meta tags had no values. Skip this name
    // also.
    if (values.length == 1 && values[0] != null) {
      String? metaValue;
      // Meta values that contain HTML should be stripped, as they
      // weren't subject to cleaning previously.
      if (cleanTags) {
        metaValue = stripTags(values[0]!, document);
      } else {
        metaValue = values[0];
      }
      return metaValue;
    }
  }

  // If nothing is found, return null
  return null;
}
