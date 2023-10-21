bool isHTTP(String url) =>
    Uri.parse(url).isScheme('http') || Uri.parse(url).isScheme('https');
