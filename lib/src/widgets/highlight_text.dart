import 'package:flutter/material.dart';

class HighlightText extends StatelessWidget {
  const HighlightText({
    super.key,
    required this.text,
    required this.highlight,
    required this.color,
    this.style,
    this.overflow,
    this.maxLines,
    this.textSpans,
  });

  final String text;
  final String highlight;
  final Color color;
  final TextStyle? style;
  final TextOverflow? overflow;
  final int? maxLines;
  final List<InlineSpan>? textSpans;

  @override
  Widget build(BuildContext context) {
    final search = highlight.toLowerCase();
    final matches = search.allMatches(text.toLowerCase()).toList();
    final spans = <TextSpan>[];

    if (matches.isEmpty) {
      spans.add(TextSpan(text: text, style: style));
    } else {
      for (var i = 0; i < matches.length; i++) {
        final strStart = i == 0 ? 0 : matches[i - 1].end;
        final match = matches[i];
        spans.add(
          normalSpan(text.substring(strStart, match.start)),
        );
        spans.add(
          highlightSpan(text.substring(match.start, match.end)),
        );
      }
      spans.add(
        normalSpan(text.substring(matches.last.end)),
      );
    }

    return Text.rich(
      TextSpan(
        children: [...spans, ...textSpans ?? []],
      ),
      overflow: overflow,
      maxLines: maxLines,
    );
  }

  TextSpan highlightSpan(String content) {
    return TextSpan(
        text: content, style: style?.copyWith(backgroundColor: color));
  }

  TextSpan normalSpan(String content) {
    return TextSpan(text: content, style: style);
  }
}
