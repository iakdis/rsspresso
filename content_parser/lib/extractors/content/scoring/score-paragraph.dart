import 'package:content_parser/extractors/content/scoring/score-commas.dart';
import 'package:content_parser/extractors/content/scoring/score-length.dart';
import 'package:universal_html/html.dart';

// Score a paragraph using various methods. Things like the number of
// commas, etc. Higher is better.
int scoreParagraph(Element node) {
  int score = 1;
  final text = node.text!.trim();
  final textLength = text.length;

  // If this paragraph is less than 25 characters, don't count it.
  if (textLength < 25) {
    return 0;
  }

  // Add points for any commas within this paragraph.
  score += scoreCommas(text);

  // For every 50 characters in this paragraph, add another point. Up
  // to 3 points.
  score += scoreLength(textLength);

  // Articles can end with short paragraphs when people are being clever,
  // but they can also end with short paragraphs setting up lists of junk
  // that we strip. This negative tweaks junk setup paragraphs just below
  // the cutoff threshold.
  if (text.endsWith(':')) {
    score -= 1;
  }

  return score;
}
