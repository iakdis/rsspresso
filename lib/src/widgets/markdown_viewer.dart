import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/font_size_provider.dart';
import '../providers/text_direction.dart';
import 'snackbar.dart';

class MarkdownViewer extends ConsumerWidget {
  const MarkdownViewer({super.key, required this.content});

  final String content;

  Widget _imageBuilder(Uri uri, String? title, String? alt,
      {String? imageDirectory, double? width, double? height}) {
    if (uri.toString().endsWith('.svg')) return Container();

    final Widget image;

    final Widget networkImage = CachedNetworkImage(
      imageUrl: uri.toString(),
      width: width,
      height: height,
      fadeInDuration: const Duration(milliseconds: 200),
    );

    if (uri.scheme == 'http' || uri.scheme == 'https') {
      image = networkImage;
    } else if (uri.scheme == 'data') {
      image = _handleDataSchemeUri(uri, width, height);
    } else if (uri.scheme == 'resource') {
      image = Image.asset(uri.path, width: width, height: height);
    } else {
      final Uri fileUri = imageDirectory != null
          ? Uri.parse(imageDirectory + uri.toString())
          : uri;
      if (fileUri.scheme == 'http' || fileUri.scheme == 'https') {
        image = networkImage;
      } else {
        image = Image.file(File.fromUri(fileUri), width: width, height: height);
      }
    }

    return Tooltip(
      message: alt,
      verticalOffset: 100,
      waitDuration: const Duration(seconds: 1),
      margin: const EdgeInsets.symmetric(horizontal: 64.0),
      child: image,
    );
  }

  Widget _handleDataSchemeUri(
      Uri uri, final double? width, final double? height) {
    final String mimeType = uri.data!.mimeType;
    if (mimeType.startsWith('image/')) {
      return Image.memory(
        uri.data!.contentAsBytes(),
        width: width,
        height: height,
      );
    } else if (mimeType.startsWith('text/')) {
      return Text(uri.data!.contentAsString());
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markdown = html2md.convert(content);

    return Markdown(
      physics: const NeverScrollableScrollPhysics(),
      data: markdown,
      selectable: true,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      styleSheet: MarkdownStyleSheet(
        textAlign: ref.watch(textDirectionProvider) == TextDirection.rtl
            ? WrapAlignment.end
            : WrapAlignment.start,
        p: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(fontSize: ref.watch(fontSizeProvider)),
        code: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'monospace',
              fontSize: ref.watch(fontSizeProvider),
            ),
        blockquotePadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        blockquoteDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          border: Border(
            left: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 6.0,
            ),
          ),
        ),
      ),
      imageBuilder: (uri, title, alt) => _imageBuilder(uri, title, alt),
      onTapLink: (text, href, title) async {
        if (href == null) return;
        final uri = Uri.parse(href);

        showErrorSnackbar() {
          showSnackbar(
              text: 'Could not open link "$href"',
              seconds: 2,
              context: context);
        }

        if (uri.scheme == 'http' || uri.scheme == 'https') {
          if (!await launchUrl(uri)) {
            showErrorSnackbar();
          }
        } else {
          showErrorSnackbar();
        }
      },
    );
  }
}
