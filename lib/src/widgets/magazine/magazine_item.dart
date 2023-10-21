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
import '../lead_image.dart';
import '../scale_tap.dart';

class MagazineItem extends ConsumerWidget {
  const MagazineItem({
    super.key,
    required this.article,
  });

  final Article article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containsImage =
        LeadImage.containsImage(htmlContent: article.htmlContent);
    final width = MediaQuery.of(context).size.width;

    return ScaleTap(
      child: Material(
        child: InkWell(
          onTap: () => openArticle(
            context: context,
            article: article,
            ref: ref,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                containsImage && width > ScreenSize.tabletWidth
                    ? LeadImage(
                        htmlContent: article.htmlContent,
                        width: 200.0,
                        height: 160.0,
                      )
                    : const SizedBox(height: 160.0),
                Expanded(
                  child: SizedBox(
                    height: 136.0,
                    child: ListTile(
                      minVerticalPadding: 0,
                      contentPadding:
                          containsImage && width > ScreenSize.tabletWidth
                              ? const EdgeInsets.only(left: 24.0)
                              : null,
                      isThreeLine: true,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HighlightText(
                            text: article.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            highlight: ref.watch(searchProvider),
                            color: markedTextColor(
                                brightness: Theme.of(context).brightness),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 12.0),
                            child: Text(
                              article.textContent.split('\n').join(' '),
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Favicon(
                                  url: article.favicon,
                                  width: 20.0,
                                  height: 20.0,
                                ),
                                const SizedBox(width: 8.0),
                                Flexible(
                                  child: Text(
                                    article.author,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
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
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
