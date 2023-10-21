RegExp idkRe = RegExp(r'^(p|pre)$', caseSensitive: false);

// Score based on the text length and the tag name.
int scoreLength(int textLength, [String tagName = 'p']) {
  double chunks = textLength / 50;

  if (chunks > 0) {
    double lengthBonus;

    // No idea why p or pre are being tamped down here
    // but just following the source for now
    // Not even sure why tagName is included here,
    // since this is only being called from the context
    // of scoreParagraph
    if (idkRe.hasMatch(tagName)) {
      lengthBonus = chunks - 2;
    } else {
      lengthBonus = chunks - 1.25;
    }

    return (lengthBonus.clamp(0, 3)).toInt();
  }

  return 0;
}
