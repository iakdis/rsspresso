// Function to resolve absolute URLs for the given attribute
import 'package:universal_html/html.dart';

void absolutize(DocumentFragment doc, String rootUrl, String attr) {
  final baseUrl = doc.querySelector('base')?.attributes['href'];

  doc.querySelectorAll('[$attr]').forEach((node) {
    final attrs = node.attributes;
    final url = attrs[attr] ?? '';
    if (url.isEmpty) return;

    final absoluteUrl = Uri.parse(baseUrl ?? rootUrl).resolve(url).toString();

    node.attributes[attr] = absoluteUrl;
  });
}

void absolutizeSet(String rootUrl, Element contentElement) {
  for (final node in contentElement.querySelectorAll('[srcset]')) {
    final urlSet = node.attributes['srcset'];
    if (urlSet != null) {
      // a comma should be considered part of the candidate URL unless preceded by a descriptor
      // descriptors can only contain positive numbers followed immediately by either 'w' or 'x'
      // space characters inside the URL should be encoded (%20 or +)
      final candidates = RegExp(r'(?:\s*)(\S+(?:\s*[\d.]+[wx])?)(?:\s*,\s*)?')
          .allMatches(urlSet);
      if (candidates.isEmpty) continue;
      final absoluteCandidates = candidates.map((candidate) {
        // a candidate URL cannot start or end with a comma
        // descriptors are separated from the URLs by unescaped whitespace
        final parts = candidate
            .group(1)!
            .trim()
            .replaceAll(RegExp(r',$'), '')
            .split(RegExp(r'\s+'));
        parts[0] = Uri.parse(rootUrl).resolve(parts[0]).toString();
        return parts.join(' ');
      }).toSet();
      final absoluteUrlSet = absoluteCandidates.join(', ');
      node.attributes['srcset'] = absoluteUrlSet;
    }
  }
}

// Main function to make links absolute in the content
Element makeLinksAbsolute(
    Element content, DocumentFragment doc, String? rootUrl) {
  if (rootUrl == null) return content;
  for (var attr in ['href', 'src']) {
    absolutize(doc, rootUrl, attr);
  }
  absolutizeSet(rootUrl, content);

  return content;
}
