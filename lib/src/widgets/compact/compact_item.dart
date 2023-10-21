import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/article.dart';
import '../../pages/article_page.dart';
import '../../providers/has_read_provider.dart';
import '../../providers/search_provider.dart';
import '../../themes/theme.dart';
import '../../utils/globals.dart';
import '../date_difference.dart';
import '../favicon.dart';
import '../highlight_text.dart';

class CompactItem extends ConsumerWidget {
  const CompactItem({
    super.key,
    required this.article,
  });

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;

    return Material(
      child: ListTile(
        dense: true,
        title: Row(
          children: [
            Favicon(
              url: article.favicon,
              width: 18.0,
              height: 18.0,
            ),
            const SizedBox(width: 6.0),
            if (width > ScreenSize.tabletWidth)
              SizedBox(
                width: 120,
                child: Text(
                  article.author,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            const SizedBox(width: 4.0),
            Flexible(
              child: HighlightText(
                text: article.title,
                style: Theme.of(context).textTheme.labelLarge,
                highlight: ref.watch(searchProvider),
                color:
                    markedTextColor(brightness: Theme.of(context).brightness),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textSpans: [
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: article.textContent.split('\n').join(' '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Consumer(
          builder: (context, ref, child) {
            ref.watch(hasReadProvider);

            return DateDifference(
              date: article.date,
              hasRead: ref.watch(hasReadProvider.notifier).get(article.id),
              dense: true,
            );
          },
        ),
        onTap: () => openArticle(
          context: context,
          article: article,
          ref: ref,
        ),
      ),
    );
  }
}
