import 'package:content_parser/extractors/content/extractor.dart';
import 'package:flutter/material.dart' hide SubmenuButton;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../providers/font_size_provider.dart';
import '../providers/has_read_provider.dart';
import '../providers/selected_article_provider.dart';
import '../providers/text_direction.dart';
import '../utils/blur_page.dart';
import '../utils/date.dart';
import '../utils/globals.dart';
import '../utils/preferences/preferences.dart';
import '../widgets/appbar/appbar.dart';
import '../widgets/markdown_viewer.dart';
import '../models/article.dart';

class ArticlePage extends ConsumerStatefulWidget {
  const ArticlePage({super.key, this.openAsDialog = true});

  final bool openAsDialog;

  @override
  ConsumerState<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends ConsumerState<ArticlePage> {
  final ScrollController controller = ScrollController();

  bool loadFullContent = false;

  Future<String?> getFullContent({required String url}) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final extracted = GenericContentExtractor().extractAsString(
        response.body,
        title: 'title',
        url: url,
      );

      return extracted;
    } else {
      return null;
    }
  }

  Widget nextPrevArticleButton({
    required Article article,
    required bool next,
    bool enabled = true,
  }) {
    return IconButton.filledTonal(
      tooltip: next ? 'Next' : 'Previous',
      onPressed: enabled
          ? () => openArticle(
                context: context,
                article: next ? article.next! : article.previous!,
                ref: ref,
                openInNew: false,
              )
          : null,
      icon:
          next ? const Icon(Icons.arrow_forward) : const Icon(Icons.arrow_back),
      iconSize: 28.0,
      padding: const EdgeInsets.all(12.0),
      style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(
              Theme.of(context).colorScheme.primaryContainer)),
    );
  }

  ArticleAppBar articleAppBar(BuildContext context, AppBarType appBarType,
      {required Article article}) {
    return ArticleAppBar(
      context: context,
      ref: ref,
      article: article,
      appBarType: appBarType,
      openAsDialog: widget.openAsDialog,
      loadFullContent: loadFullContent,
      setLoadFullContent: () =>
          setState(() => loadFullContent = !loadFullContent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final article = ref.watch(selectedArticleProvider);
    final width = MediaQuery.of(context).size.width;

    if (article == null) {
      return Center(
        child: SelectableText(
          'No article selected',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (width > ScreenSize.tabletWidth) ...[
          if (widget.openAsDialog) const SizedBox(width: 8.0),
          if (article.previous != null && widget.openAsDialog)
            nextPrevArticleButton(article: article, next: false),
          if (article.previous == null && widget.openAsDialog)
            const SizedBox(width: 52.0),
          if (widget.openAsDialog) const SizedBox(width: 8.0),
        ],
        Expanded(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ScaffoldMessenger(
                child: Builder(builder: (context) {
                  return ClipRRect(
                    borderRadius: width > ScreenSize.tabletWidth
                        ? BorderRadius.circular(6.0)
                        : BorderRadius.zero,
                    child: Scaffold(
                      appBar:
                          widget.openAsDialog && width > ScreenSize.tabletWidth
                              ? articleAppBar(
                                  context,
                                  AppBarType.desktopTop,
                                  article: article,
                                ).appBar()
                              : null,
                      bottomNavigationBar: !widget.openAsDialog ||
                              width <= ScreenSize.tabletWidth
                          ? SizedBox(
                              height: 56.0,
                              child: articleAppBar(
                                context,
                                width <= ScreenSize.tabletWidth
                                    ? AppBarType.mobileBottom
                                    : AppBarType.desktopBottom,
                                article: article,
                              ).appBar(),
                            )
                          : null,
                      body: Scrollbar(
                        controller: controller,
                        thumbVisibility: true,
                        child: CustomScrollView(
                          controller: controller,
                          slivers: [
                            if (widget.openAsDialog &&
                                width <= ScreenSize.tabletWidth)
                              articleAppBar(
                                context,
                                AppBarType.mobileTop,
                                article: article,
                              ).sliverAppBar(),
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  Padding(
                                    padding: width > ScreenSize.tabletWidth
                                        ? const EdgeInsets.fromLTRB(
                                            64.0, 16.0, 64.0, 64.0)
                                        : const EdgeInsets.fromLTRB(
                                            32.0, 16.0, 32.0, 128.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SelectableText(
                                          article.title,
                                          textDirection:
                                              ref.watch(textDirectionProvider),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(
                                                  fontSize: ref.watch(
                                                          fontSizeProvider) +
                                                      8),
                                        ),
                                        SelectableText(
                                          parseDate(article.date),
                                          textDirection:
                                              ref.watch(textDirectionProvider),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                  fontSize: ref
                                                      .watch(fontSizeProvider)),
                                        ),
                                        const SizedBox(height: 16.0),
                                        if (loadFullContent)
                                          FutureBuilder(
                                            future: getFullContent(
                                                url: article.link),
                                            builder: (context, snapshot) {
                                              return Column(
                                                children: [
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting)
                                                    const LinearProgressIndicator(
                                                        minHeight: 6.0),
                                                  MarkdownViewer(
                                                      content: snapshot
                                                                  .hasData &&
                                                              snapshot.data !=
                                                                  null
                                                          ? snapshot.data!
                                                          : article
                                                              .htmlContent),
                                                ],
                                              );
                                            },
                                          )
                                        else
                                          MarkdownViewer(
                                              content: article.htmlContent),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        if (width > ScreenSize.tabletWidth) ...[
          if (widget.openAsDialog) const SizedBox(width: 8.0),
          if (article.next != null && widget.openAsDialog)
            nextPrevArticleButton(article: article, next: true),
          if (article.next == null && widget.openAsDialog)
            const SizedBox(width: 52.0),
          if (widget.openAsDialog) const SizedBox(width: 8.0),
        ],
      ],
    );
  }
}

void openArticle({
  required BuildContext context,
  required Article article,
  required WidgetRef ref,
  bool openInNew = true,
}) {
  ref.read(selectedArticleProvider.notifier).state = article;

  PrefHasRead().set(article.id, true);
  ref.read(hasReadProvider.notifier).refresh();

  if (!openInNew) return;

  Navigator.of(context).push(blurPage(
    page: const ArticlePage(),
    maxWidth: PageSize.articleWidth,
    blurAmount:
        MediaQuery.of(context).size.width > ScreenSize.tabletWidth ? 12 : null,
  ));
}

enum AppBarType {
  desktopTop,
  desktopBottom,
  mobileTop,
  mobileBottom,
}
