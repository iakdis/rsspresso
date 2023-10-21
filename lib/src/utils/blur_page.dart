import 'dart:ui';
import 'package:flutter/material.dart';

import 'globals.dart';

PageRouteBuilder blurPage({
  required Widget page,
  required double maxWidth,
  double? blurAmount,
}) {
  return PageRouteBuilder(
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    pageBuilder: (context, animation, secondaryAnimation) =>
        LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final padding = (width > maxWidth) ? (width - maxWidth) / 2 : 0.0;
      final screenWidth = MediaQuery.of(context).size.width;

      return Padding(
        padding: screenWidth > ScreenSize.tabletWidth
            ? EdgeInsets.symmetric(vertical: 24.0, horizontal: padding)
            : EdgeInsets.zero,
        child: page,
      );
    }),
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (ctx, anim1, anim2, child) => blurAmount != null
        ? BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: blurAmount * anim1.value,
                sigmaY: blurAmount * anim1.value),
            child: FadeTransition(
              opacity: anim1,
              child: child,
            ),
          )
        : FadeTransition(opacity: anim1, child: child),
  );
}
