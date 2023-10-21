// Given a string, return true if it appears to have an ending sentence
// within it, false otherwise.
bool hasSentenceEnd(String text) {
  final RegExp sentenceEndRe = RegExp(r'.( |$)');
  return sentenceEndRe.hasMatch(text);
}
