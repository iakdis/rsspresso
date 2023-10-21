// import 'package:html/parser.dart' show parse;
import 'package:universal_html/html.dart';

import '../../cleaners/content.dart';
import '../../utils/dom/node-is-sufficient.dart';
import '../../utils/text/normalize-spaces.dart';

import 'extract-best-node.dart';

class Options {
  static const stripUnlikelyCandidates = 'stripUnlikelyCandidates';
  static const weightNodes = 'weightNodes';
  static const cleanConditionally = 'cleanConditionally';
}

class GenericContentExtractor {
  Map<String, bool> defaultOpts = {
    Options.stripUnlikelyCandidates: true,
    Options.weightNodes: true,
    Options.cleanConditionally: true,
  };

  // Extract the content for this resource - initially, pass in our
  // most restrictive opts which will return the highest quality
  // content. On each failure, retry with slightly more lax opts.
  //
  // :param return_type: string. If "node", should return the content
  // as a DOM node rather than as an HTML string.
  //
  // Opts:
  // stripUnlikelyCandidates: Remove any elements that match
  // non-article-like criteria first.(Like, does this element
  // have a classname of "comment")
  //
  // weightNodes: Modify an elements score based on whether it has
  // certain classNames or IDs. Examples: Subtract if a node has
  // a className of 'comment', Add if a node has an ID of
  // 'entry-content'.
  //
  // cleanConditionally: Clean the node to return of some
  // superfluous content. Things like forms, ads, etc.
  dynamic _extract(
    String html, {
    required String title,
    required String url,
    required Map<String, bool>? opts,
    required bool asString,
  }) {
    opts = {...defaultOpts, ...?opts};

    var doc = DocumentFragment.html(html);

    // Cascade through our extraction-specific opts in an ordered fashion,
    // turning them off as we try to extract content.
    var node = getContentNode(doc, title: title, url: url, opts: opts);

    if (nodeIsSufficient(node)) {
      return asString ? cleanAndReturnNode(node, doc) : node;
    }

    // We didn't succeed on first pass, one by one disable our
    // extraction opts and try again.
    for (var key in opts.keys.where((k) => opts?[k] == true)) {
      opts[key] = false;
      doc = DocumentFragment.html(html);

      node = getContentNode(doc, title: title, url: url, opts: opts);

      if (nodeIsSufficient(node)) {
        break;
      }
    }

    return asString ? cleanAndReturnNode(node, doc) : node;
  }

  String extractAsString(
    String html, {
    required String title,
    required String url,
    Map<String, bool>? opts,
  }) {
    return _extract(
      html,
      title: title,
      url: url,
      opts: opts,
      asString: true,
    ) as String;
  }

  Element extractAsElement(
    String html, {
    required String title,
    required String url,
    Map<String, bool>? opts,
  }) {
    return _extract(
      html,
      title: title,
      url: url,
      opts: opts,
      asString: false,
    ) as Element;
  }

  // Get node given current options
  Element getContentNode(DocumentFragment doc,
      {String? title, String? url, Map<String, bool>? opts}) {
    return extractCleanNode(
      article: extractBestNode(doc, opts),
      document: doc,
      cleanConditionally: opts?[Options.cleanConditionally] ?? true,
      title: title,
      url: url,
    );
  }

  // Once we got here, either we're at our last-resort node, or
  // we broke early. Make sure we at least have -something- before we
  // move forward.
  String cleanAndReturnNode(Element node, DocumentFragment document) {
    return normalizeSpaces(node.outerHtml!);
  }
}
