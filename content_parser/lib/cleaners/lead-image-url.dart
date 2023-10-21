String? cleanImage(String leadImageUrl) {
  leadImageUrl = leadImageUrl.trim();
  if (isValidUrl(leadImageUrl)) {
    return leadImageUrl;
  }

  return null;
}

bool isValidUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null && uri.hasAbsolutePath;
}
