import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/feed.dart';
import '../../providers/has_read_provider.dart';
import '../../providers/load_articles_provider.dart';
import '../../providers/selected_article_provider.dart';
import '../../providers/selected_feed_provider.dart';
import '../../utils/cache.dart';
import '../../utils/favicon.dart';
import '../favicon.dart';

class FeedTile extends ConsumerStatefulWidget {
  const FeedTile({
    super.key,
    required this.url,
    required this.canPop,
    required this.customFunction,
  });

  factory FeedTile.all({
    bool canPop = false,
    void Function()? customFunction,
  }) =>
      FeedTile(
        url: null,
        canPop: canPop,
        customFunction: customFunction,
      );

  factory FeedTile.feed({
    required String url,
    bool canPop = false,
    void Function()? customFunction,
  }) =>
      FeedTile(
        url: url,
        canPop: canPop,
        customFunction: customFunction,
      );

  final String? url;
  final bool canPop;
  final void Function()? customFunction;

  @override
  ConsumerState<FeedTile> createState() => _FeedTileState();
}

class _FeedTileState extends ConsumerState<FeedTile> {
  String? _unreadAmountString({
    String? url,
    bool dontCheckFeed = false,
  }) {
    ref.watch(hasReadProvider);
    final unreadAmount =
        Feed.unreadAmount(ref, url: url, dontCheckFeed: dontCheckFeed);

    String? unreadString = unreadAmount.toString();
    if (unreadAmount <= 0) unreadString = null;
    if (unreadAmount > 999) unreadString = '999+';

    return unreadString;
  }

  void _setCurrentFeed({required Feed? feed}) async {
    ref.read(selectedFeedProvider.notifier).state = feed;
    ref.read(selectedArticleProvider.notifier).state = null;

    var loadType = LoadType.cached;

    // If specific cached feed does not exist, load from online
    if (feed != null &&
        !Cache.containsFeedPath(feedsUri: Uri.parse(feed.url))) {
      loadType = LoadType.online;
    }

    ref.read(loadArticlesProvider.notifier).refreshArticles(loadType);
  }

  Widget _feedTile({
    required String title,
    required bool isSelected,
    required String? unreadAmount,
    required Widget leading,
    required Feed? feed,
    required bool canPop,
  }) {
    return ListTile(
      title: Tooltip(
        message: title,
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      leading: leading,
      trailing: unreadAmount != null ? Text(unreadAmount) : null,
      onTap: widget.customFunction ??
          (isSelected
              ? () {}
              : () {
                  if (canPop) Navigator.pop(context);
                  _setCurrentFeed(feed: feed);
                }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url == null) {
      final unreadString = _unreadAmountString(dontCheckFeed: true);
      final isSelected = ref.watch(selectedFeedProvider) == null;

      return _feedTile(
        title: 'All articles',
        unreadAmount: unreadString,
        isSelected: isSelected,
        leading: isSelected
            ? const Icon(Icons.all_inbox)
            : const Icon(Icons.all_inbox_outlined),
        feed: null,
        canPop: widget.canPop,
      );
    } else {
      return FutureBuilder(
        future: Cache.loadFeed(ref: ref, url: widget.url!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final loadedFeed = snapshot.data!;
            final author = loadedFeed.author!;
            final firstItemLink = loadedFeed.favicon!;

            final unreadString = _unreadAmountString(url: widget.url);
            final isSelected =
                ref.watch(selectedFeedProvider)?.url == widget.url;

            return _feedTile(
              title: author,
              unreadAmount: unreadString,
              isSelected: isSelected,
              leading: FutureBuilder(
                  future: fetchFavicon(url: firstItemLink),
                  builder: (context, snapshot) {
                    return Favicon(
                      url: snapshot.data,
                      width: 24.0,
                      height: 24.0,
                    );
                  }),
              feed: Feed(url: widget.url!),
              canPop: widget.canPop,
            );
          }
          return const ListTile();
        },
      );
    }
  }
}
