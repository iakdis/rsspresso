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
import '../scale_tap.dart';

class CardItem extends ConsumerWidget {
  const CardItem({
    super.key,
    required this.article,
    this.isMobile = false,
  });

  final Article article;
  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final containsImage =
        LeadImage.containsImage(htmlContent: article.htmlContent);

    return ScaleTap(
      lowerBound: 0.94,
      child: Card(
        elevation: 3.0,
        child: GestureDetector(
          onTap: () => openArticle(
            context: context,
            article: article,
            ref: ref,
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: LeadImage(
                    htmlContent: article.htmlContent,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Container(
                height: (containsImage ? 128.0 : 256.0) - (isMobile ? 24.0 : 0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: ListTile(
                  dense: true,
                  isThreeLine: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
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
                            const SizedBox(width: 6.0),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HighlightText(
                          text: article.title,
                          style: Theme.of(context).textTheme.bodyLarge,
                          highlight: ref.watch(searchProvider),
                          color: markedTextColor(
                              brightness: Theme.of(context).brightness),
                          overflow: TextOverflow.ellipsis,
                          maxLines: isMobile ? 2 : 3,
                        ),
                        if (!containsImage) ...[
                          const SizedBox(height: 8.0),
                          Text(
                            article.textContent,
                            style: Theme.of(context).textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                            maxLines: isMobile ? 5 : 6,
                          ),
                        ],
                      ],
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
