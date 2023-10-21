import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/article.dart';
import '../../pages/article_page.dart';
import '../../providers/has_read_provider.dart';
import '../../providers/search_provider.dart';
import '../../themes/theme.dart';
import '../date_difference.dart';
import '../favicon.dart';
import '../highlight_text.dart';
import '../lead_image.dart';

class ListItem extends ConsumerWidget {
  const ListItem({
    super.key,
    required this.article,
    this.openInNew = false,
  });

  final Article article;
  final bool openInNew;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containsImage =
        LeadImage.containsImage(htmlContent: article.htmlContent);

    return Material(
      child: InkWell(
        onTap: () => openArticle(
          context: context,
          article: article,
          ref: ref,
          openInNew: openInNew,
        ),
        child: Padding(
          padding: containsImage
              ? const EdgeInsets.all(6.0)
              : const EdgeInsets.all(4.0),
          child: Row(
            children: [
              LeadImage(
                htmlContent: article.htmlContent,
                width: 80.0,
                height: 80.0,
              ),
              Expanded(
                child: SizedBox(
                  height: 80.0,
                  child: ListTile(
                    minVerticalPadding: 2.0,
                    dense: true,
                    isThreeLine: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12.0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Favicon(
                                url: article.favicon,
                                width: 16.0,
                                height: 16.0,
                              ),
                              const SizedBox(width: 4.0),
                              Flexible(
                                child: Text(
                                  article.author,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Consumer(
                          builder: (context, ref, child) {
                            ref.watch(hasReadProvider);

                            return DateDifference(
                              date: article.date,
                              hasRead: ref
                                  .watch(hasReadProvider.notifier)
                                  .get(article.id),
                              dense: true,
                            );
                          },
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: HighlightText(
                        text: article.title,
                        style: Theme.of(context).textTheme.bodyMedium,
                        highlight: ref.watch(searchProvider),
                        color: markedTextColor(
                            brightness: Theme.of(context).brightness),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
