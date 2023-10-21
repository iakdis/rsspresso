import 'package:flutter/material.dart' hide SubmenuButton;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/article.dart';
import '../../pages/article_page.dart';
import '../../providers/font_size_provider.dart';
import '../../providers/has_read_provider.dart';
import '../../providers/has_star_provider.dart';
import '../../providers/load_articles_provider.dart';
import '../../providers/selected_article_provider.dart';
import '../../providers/text_direction.dart';
import '../../utils/globals.dart';
import '../../utils/preferences/preferences.dart';
import '../favicon.dart';
import '../menu.dart';
import '../snackbar.dart';

class ArticleAppBar {
  const ArticleAppBar({
    required this.context,
    required this.ref,
    required this.article,
    required this.appBarType,
    required this.openAsDialog,
    required this.loadFullContent,
    required this.setLoadFullContent,
  });

  final BuildContext context;
  final WidgetRef ref;
  final Article article;
  final AppBarType appBarType;
  final bool loadFullContent;
  final void Function() setLoadFullContent;
  final bool openAsDialog;

  Future<void> openInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      print('Could not launch $uri');
    }
  }

  Widget _outlinedIconButton({
    required bool outlined,
    required void Function()? onPressed,
    required Widget icon,
    String? tooltip,
  }) {
    return outlined
        ? IconButton.outlined(
            onPressed: onPressed,
            tooltip: tooltip,
            icon: icon,
          )
        : IconButton(
            onPressed: onPressed,
            tooltip: tooltip,
            icon: icon,
          );
  }

  Widget _articleActions({required BuildContext context}) {
    final width = MediaQuery.of(context).size.width;

    final article = ref.watch(selectedArticleProvider)!;
    final hasRead = ref.watch(hasReadProvider)[article.id] ?? true;
    final hasStar = ref.watch(hasStarProvider)[article.id] ?? false;

    return Wrap(
      spacing: width > ScreenSize.tabletWidth ? 4.0 : 0,
      children: [
        IconButton(
          onPressed: () async {
            await PrefHasRead().set(article.id, !hasRead);
            ref.read(hasReadProvider.notifier).refresh();
            ref.read(loadArticlesProvider.notifier).refreshArticlesProvider();

            if (context.mounted) {
              showSnackbar(
                text: hasRead ? 'Marked as unread' : 'Marked as read',
                seconds: 1,
                context: context,
              );
            }
          },
          tooltip: hasRead ? 'Mark as unread' : 'Mark as read',
          icon:
              Icon(hasRead ? Icons.visibility : Icons.visibility_off_outlined),
        ),
        IconButton(
          onPressed: () async {
            await PrefHasStar().set(article.id, !hasStar);
            ref.read(hasStarProvider.notifier).refresh();
            ref.read(loadArticlesProvider.notifier).refreshArticlesProvider();

            if (context.mounted) {
              showSnackbar(
                text: hasStar ? 'Unsaved article' : 'Saved article',
                seconds: 1,
                context: context,
              );
            }
          },
          tooltip: hasStar ? 'Unsave article' : 'Save article',
          icon: Icon(hasStar ? Icons.star : Icons.star_border),
        ),
        _outlinedIconButton(
          outlined: loadFullContent,
          onPressed: () {
            setLoadFullContent();
          },
          tooltip: 'Load full content',
          icon: const Icon(Icons.notes),
        ),
        IconButton(
          onPressed: () => openInBrowser(article.link),
          tooltip: 'Open in Browser',
          icon: const Icon(Icons.open_in_new),
        ),
        Menu(
          icon: Icons.more_vert,
          menuChildren: [
            MenuButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: article.link));
                if (context.mounted) {
                  showSnackbar(
                    text: 'Link copied to clipboard',
                    seconds: 2,
                    context: context,
                  );
                }
              },
              icon: Icons.link,
              text: 'Copy link',
            ),
            // if (width <= ScreenSize.tabletWidth)
            // MenuButton(
            //   onPressed: () => openInBrowser(article.link),
            //   icon: Icons.open_in_new,
            //   text: 'Open in Browser',
            // ),
            Submenu(
              text: 'Font size',
              icon: Icons.format_size,
              menuChildren: <Widget>[
                for (var i = minFontSize; i <= maxFontSize; i++)
                  SubmenuButton(
                    onPressed: () =>
                        ref.read(fontSizeProvider.notifier).set(i.toDouble()),
                    text: i.toInt().toString().padLeft(4).padRight(6),
                    trailing: ref.watch(fontSizeProvider) == i.toDouble()
                        ? const Icon(Icons.check)
                        : null,
                  ),
              ],
            ),
            Submenu(
              text: 'Text direction',
              icon: Icons.format_textdirection_l_to_r,
              menuChildren: <Widget>[
                SubmenuButton(
                  onPressed: () => ref
                      .read(textDirectionProvider.notifier)
                      .set(TextDirection.ltr),
                  icon: Icons.arrow_forward,
                  text: 'Left-to-right',
                  trailing:
                      ref.watch(textDirectionProvider) == TextDirection.ltr
                          ? const Icon(Icons.check)
                          : null,
                ),
                SubmenuButton(
                  onPressed: () => ref
                      .read(textDirectionProvider.notifier)
                      .set(TextDirection.rtl),
                  icon: Icons.arrow_back,
                  text: 'Right-to-left',
                  trailing:
                      ref.watch(textDirectionProvider) == TextDirection.rtl
                          ? const Icon(Icons.check)
                          : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _nextPrevArticleButton({
    required Article article,
    required bool next,
    bool enabled = true,
  }) {
    return IconButton(
      tooltip: next ? 'Next' : 'Previous',
      onPressed: enabled
          ? () => openArticle(
                context: context,
                article: next ? article.next! : article.previous!,
                ref: ref,
                openInNew: false,
              )
          : null,
      icon: next
          ? const Icon(Icons.keyboard_arrow_down)
          : const Icon(Icons.keyboard_arrow_up),
      iconSize: 28.0,
    );
  }

  AppBar appBar() {
    final width = MediaQuery.of(context).size.width;

    return AppBar(
      backgroundColor:
          openAsDialog ? Theme.of(context).colorScheme.inversePrimary : null,
      automaticallyImplyLeading: false,
      titleSpacing: width > ScreenSize.tabletWidth &&
              appBarType != AppBarType.desktopBottom
          ? 8.0
          : 12.0,
      leading: openAsDialog && appBarType != AppBarType.mobileBottom
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: width > ScreenSize.tabletWidth ||
              appBarType == AppBarType.mobileBottom
          ? Padding(
              padding: EdgeInsets.zero, //const EdgeInsets.only(left: 64.0),
              child: Row(
                children: [
                  Tooltip(
                    message: article.author,
                    child: Favicon(
                      url: article.favicon,
                      width: 32.0,
                      height: 32.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Flexible(
                    child: SelectableText(
                      article.author,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            )
          : null,
      actions: appBarType != AppBarType.mobileBottom
          ? [
              _articleActions(context: context),
              const SizedBox(width: 8.0),
            ]
          : [
              _nextPrevArticleButton(
                enabled: article.previous != null,
                article: article,
                next: false,
              ),
              const SizedBox(width: 4.0),
              _nextPrevArticleButton(
                enabled: article.next != null,
                article: article,
                next: true,
              ),
              const SizedBox(width: 8.0),
            ],
    );
  }

  SliverAppBar sliverAppBar() {
    final width = MediaQuery.of(context).size.width;

    return SliverAppBar(
      // Sliver options
      floating: true,

      // Other
      backgroundColor:
          openAsDialog ? Theme.of(context).colorScheme.inversePrimary : null,
      automaticallyImplyLeading: false,
      titleSpacing: width > ScreenSize.tabletWidth ? 8.0 : 12.0,
      leading: openAsDialog && appBarType != AppBarType.mobileBottom
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: width > ScreenSize.tabletWidth ||
              appBarType == AppBarType.mobileBottom
          ? Padding(
              padding: EdgeInsets.zero, //const EdgeInsets.only(left: 64.0),
              child: Row(
                children: [
                  Tooltip(
                    message: article.author,
                    child: Favicon(
                      url: article.favicon,
                      width: 32.0,
                      height: 32.0,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Flexible(
                    child: SelectableText(
                      article.author,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            )
          : null,
      actions: appBarType != AppBarType.mobileBottom
          ? [
              _articleActions(context: context),
              const SizedBox(width: 8.0),
            ]
          : [
              _nextPrevArticleButton(
                enabled: article.previous != null,
                article: article,
                next: false,
              ),
              const SizedBox(width: 4.0),
              if (article.next != null)
                _nextPrevArticleButton(
                  enabled: article.next != null,
                  article: article,
                  next: true,
                ),
              const SizedBox(width: 8.0),
            ],
    );
  }
}
