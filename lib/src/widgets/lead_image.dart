import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;

import '../utils/is_http.dart';

class LeadImage extends StatelessWidget {
  const LeadImage({
    super.key,
    required this.htmlContent,
    this.width,
    this.height,
  });

  final String htmlContent;
  final double? width;
  final double? height;

  static bool containsImage({required String htmlContent}) {
    final html = html_parser.parse(htmlContent);
    final images = html.querySelectorAll('img');

    if (images.isNotEmpty) {
      final src = images[0].attributes['src'];
      if (src == null) return false;

      final isSVG = src.endsWith('svg');
      if (isSVG) return false;

      return true;
    }

    return false;
  }

  Widget _image() {
    final html = html_parser.parse(htmlContent);
    final images = html.querySelectorAll('img');

    if (containsImage(htmlContent: htmlContent)) {
      final firstImage = images[0];
      final url = firstImage.attributes['src']!;

      if (isHTTP(url)) {
        return CachedNetworkImage(
          imageUrl: url,
          errorWidget: (context, url, error) => const Icon(Icons.error),
          width: width,
          height: height,
          fadeInDuration: const Duration(milliseconds: 200),
          fit: BoxFit.cover,
        );
      }
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) => _image();
}
