// import { stripUnlikelyCandidates, convertToParagraphs } from 'utils/dom';
import 'package:universal_html/html.dart';

import '../../utils/dom/convert-to-paragraphs.dart';
import '../../utils/dom/strip-unlikely-candidates.dart';
import 'extractor.dart';
import 'scoring/find-top-candidate.dart';
import 'scoring/score-content.dart';

// import { scoreContent, findTopCandidate } from './scoring';

// Using a variety of scoring techniques, extract the content most
// likely to be article text.
//
// If strip_unlikely_candidates is True, remove any elements that
// match certain criteria first. (Like, does this element have a
// classname of "comment")
//
// If weight_nodes is True, use classNames and IDs to determine the
// worthiness of nodes.
//
// Returns a cheerio object $

Element extractBestNode(DocumentFragment document, Map<String, bool>? opts) {
  if (opts?[Options.stripUnlikelyCandidates] == true) {
    document = stripUnlikelyCandidates(document);
  }

  document = convertToParagraphs(document);
  document = scoreContent(document, opts?[Options.weightNodes] ?? true);
  final topCandidate = findTopCandidate(document);

  return topCandidate;
}
