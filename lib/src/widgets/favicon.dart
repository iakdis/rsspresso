import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/is_http.dart';

class Favicon extends StatelessWidget {
  const Favicon({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });

  final String? url;
  final double width;
  final double height;

  Widget _placeholder({
    required double width,
    required double height,
  }) =>
      SizedBox(
        width: width,
        height: height,
      );

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return _placeholder(
        width: width,
        height: height,
      );
    }

    if (isHTTP(url!)) {
      return CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fadeInDuration: const Duration(milliseconds: 200),
      );
    } else {
      return FutureBuilder(
        future: File(url!).exists(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!) {
            return Image.file(
              File(url!),
              width: width,
              height: height,
            );
          }
          return _placeholder(
            width: width,
            height: height,
          );
        },
      );
    }
  }
}
