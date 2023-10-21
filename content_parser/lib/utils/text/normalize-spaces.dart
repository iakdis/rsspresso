final NORMALIZE_RE = RegExp(r'\s{2,}(?![^<>]*<\/(pre|code|textarea)>)');

String normalizeSpaces(String text) {
  return text.replaceAll(NORMALIZE_RE, ' ').trim();
}
