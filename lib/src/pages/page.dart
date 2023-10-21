import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/home_view.dart';
import '../providers/articles_provider.dart';
import '../providers/feeds_provider.dart';
import '../providers/view_provider.dart';
import '../utils/globals.dart';
import '../widgets/appbar/filter.dart';
import '../widgets/appbar/more.dart';
import '../widgets/appbar/refresh.dart';
import '../widgets/appbar/settings.dart';
import '../widgets/navigation/feed_tile.dart';
import '../models/article.dart';
import '../models/feed.dart';
import '../widgets/search_bar.dart';
import '../widgets/appbar/view.dart';
import '../providers/has_read_provider.dart';
import '../providers/load_articles_provider.dart';
import '../utils/preferences/preferences.dart';
import '../widgets/snackbar.dart';
import 'home_page.dart';
import 'settings_page.dart';

class AppPage extends ConsumerStatefulWidget {
  const AppPage({super.key});

  @override
  ConsumerState<AppPage> createState() => _AppPageState();
}

class _AppPageState extends ConsumerState<AppPage> {
  final List<Article> _currentMarkedArticles = [];
  bool isDesktopNavOpen = true;
  final bottomSheetController = ScrollController();

  @override
  void dispose() {
    bottomSheetController.dispose();
    super.dispose();
  }

  Future<void> markFeedAsRead({required Feed? feed}) async {
    Navigator.pop(context);

    // Mark all unread articles in feed as read
    _currentMarkedArticles.clear();
    for (final article in ref.watch(allArticlesProvider)) {
      final equalsFeed = feed?.url == article.feed.url;

      if (equalsFeed || feed == null) {
        final hasRead = ref.read(hasReadProvider)[article.id];
        if (hasRead == null || hasRead == false) {
          _currentMarkedArticles.add(article);
          await PrefHasRead().set(article.id, true);
        }
      }
    }

    if (context.mounted) {
      showSnackbar(
        text:
            'Marked ${_currentMarkedArticles.length} article${_currentMarkedArticles.length > 1 ? 's' : ''} as read',
        seconds: 4,
        context: context,
        undoAction: undoMarkAsRead,
      );
    }

    ref.read(hasReadProvider.notifier).refresh();
    ref.read(loadArticlesProvider.notifier).refreshArticlesProvider();
  }

  Future<void> showMarkAsRead() async {
    // Return if no unread articles
    final unreadFeeds = <Feed>[];
    int unreadTotalAmount = 0;

    for (final feed in ref.read(feedsProvider)) {
      final unreadFeedAmount = Feed.unreadAmount(ref, url: feed.url);
      unreadTotalAmount += unreadFeedAmount;

      if (unreadFeedAmount > 0) unreadFeeds.add(feed);
    }

    if (unreadTotalAmount <= 0) {
      showSnackbar(
        text: 'No unread articles',
        seconds: 2,
        context: context,
        clearSnackbars: false,
      );
      return;
    }

    return showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(maxHeight: 600),
      builder: (context) {
        return SizedBox(
          width: 500,
          child: Scrollbar(
            controller: bottomSheetController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: bottomSheetController,
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                child: Column(
                  children: [
                    Text(
                      'Mark as read',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8.0),
                    Column(
                      children: [
                        if (unreadFeeds.length > 1) ...[
                          FeedTile.all(
                            customFunction: () => markFeedAsRead(feed: null),
                          ),
                          const Divider(height: 0),
                        ],
                        for (final feed in unreadFeeds)
                          FeedTile.feed(
                            url: feed.url,
                            customFunction: () => markFeedAsRead(feed: feed),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> undoMarkAsRead() async {
    for (final article in _currentMarkedArticles) {
      await PrefHasRead().set(article.id, false);
    }
    ref.read(hasReadProvider.notifier).refresh();
    ref.read(loadArticlesProvider.notifier).refreshArticlesProvider();
  }

  List<Widget> navigationContent({required bool isMobile}) {
    return [
      if (isMobile)
        SizedBox(
          height: 48,
          child: DrawerHeader(
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.arrow_back),
              title: Text(
                'Close',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.pop(context),
            ),
          ),
        ),
      FeedTile.all(canPop: isMobile),
      Consumer(
        builder: (context, ref, child) {
          return Column(
            children: [
              for (final feed in ref.watch(feedsProvider))
                FeedTile.feed(url: feed.url, canPop: isMobile),
            ],
          );
        },
      ),
      ListTile(
        title: Text(
          'Add new feed',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        leading: const Icon(Icons.add),
        onTap: () {
          if (isMobile) Navigator.pop(context);
          openSettings(context: context);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          titleSpacing: width <= ScreenSize.tabletWidth ? 12 : 0,
          title: Row(
            children: [
              if (width > ScreenSize.tabletWidth) ...[
                IconButton(
                  onPressed: () =>
                      setState(() => isDesktopNavOpen = !isDesktopNavOpen),
                  icon: const Icon(Icons.menu),
                  padding: const EdgeInsets.all(16.0),
                ),
                const SizedBox(width: 12.0),
              ],
              const Flexible(child: ArticleSearchBar()),
            ],
          ),
          actions: [
            if (width >= ScreenSize.mobileWidth) ...[
              const RefreshButton(),
              const SizedBox(width: 4.0),
              const FilterButton(),
              const SizedBox(width: 4.0),
              const ViewButton(),
              const SizedBox(width: 8.0),
              const SettingsButton(),
            ] else
              const MoreButton(),
            const SizedBox(width: 8.0),
          ],
        ),
        drawer: width <= ScreenSize.tabletWidth
            ? NavigationDrawer(
                children: navigationContent(isMobile: true),
              )
            : null,
        body: Row(
          children: [
            if (width > ScreenSize.tabletWidth && isDesktopNavOpen) ...[
              SizedBox(
                width: 256,
                child: Column(
                  children: navigationContent(isMobile: false),
                ),
              ),
              const VerticalDivider(width: 2),
            ],
            const Expanded(child: HomePage()),
          ],
        ),
        floatingActionButton: Padding(
          padding: ref.watch(viewProvider) == HomeView.listView
              ? const EdgeInsets.only(bottom: 64.0, right: 8.0)
              : EdgeInsets.zero,
          child: FloatingActionButton(
            onPressed: showMarkAsRead,
            tooltip: 'Mark articles as read',
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: const Icon(Icons.done_all),
          ),
        ),
      );
    });
  }
}
