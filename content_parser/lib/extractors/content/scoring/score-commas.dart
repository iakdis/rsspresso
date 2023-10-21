// Return 1 for every comma in text.
int scoreCommas(String text) {
  return (RegExp(',').allMatches(text).length);
}
