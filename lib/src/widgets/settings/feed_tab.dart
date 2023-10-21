import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/feeds_provider.dart';
import '../../models/feed.dart';
import '../../providers/load_articles_provider.dart';
import '../../providers/selected_feed_provider.dart';
import '../../providers/settings_feeds_provider.dart';
import '../../utils/cache.dart';
import '../../utils/favicon.dart';
import '../../utils/globals.dart';
import '../../utils/preferences/preferences.dart';
import '../favicon.dart';
import '../snackbar.dart';
import 'feed_item.dart';
import 'import_export.dart';

class FeedTab extends ConsumerStatefulWidget {
  const FeedTab({super.key, required this.scaffoldContext});

  final BuildContext scaffoldContext;

  @override
  ConsumerState<FeedTab> createState() => FeedTabState();
}

class FeedTabState extends ConsumerState<FeedTab> {
  final controller = TextEditingController();
  bool invalidURL = false;

  @override
  void initState() {
    final items = [...ref.read(feedsProvider)];
    for (final item in items) {
      ref.read(settingsFeedsProvider)[item.url] = false;
    }

    super.initState();
  }

  void _addFeed() async {
    final text = controller.value.text;

    if (Uri.tryParse(text)?.hasAbsolutePath == true &&
        (text.startsWith('http') || text.startsWith('https'))) {
      setState(() => invalidURL = false);

      try {
        await PrefFeeds().addIfNotExisting(text);
        ref.read(feedsProvider.notifier).state = PrefFeeds().get();

        controller.text = '';
        if (!context.mounted) return;
        showSnackbar(
          text: 'Added feed "$text"',
          seconds: 4,
          context: widget.scaffoldContext,
          undoAction: null, // TODO
        );
      } on FeedAlreadyExistsException {
        showSnackbar(
            text: 'Could not add feed; feed already exists',
            seconds: 4,
            context: context);
      }
    } else {
      setState(() => invalidURL = true);
    }
  }

  void _removeSelected() async {
    final feeds = <Feed>[];
    for (final selectedFeed in ref.watch(settingsFeedsProvider).entries) {
      if (selectedFeed.value) {
        final feed = await Cache.loadFeed(ref: ref, url: selectedFeed.key);
        feeds.add(feed);
      }
    }

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => removeDialog(
        context: context,
        feeds: feeds,
        onButtonYes: () {
          for (final feed in feeds) {
            removeFeed(ref, url: feed.url);
          }

          showSnackbar(
            text: 'Removed ${feeds.length} feed${feeds.length > 1 ? 's' : ''}',
            seconds: 4,
            context: widget.scaffoldContext,
            undoAction: null, // TODO
          );
        },
      ),
    );

    setState(() {});
  }

  static void removeFeed(WidgetRef ref, {required String url}) async {
    await Cache.deleteFavicon(feedsUri: Uri.parse(url));
    await Cache.deleteCachedFeed(feedsUri: Uri.parse(url));

    await PrefFeeds().remove(url);
    ref.read(feedsProvider.notifier).state = PrefFeeds().get();
    ref.read(settingsFeedsProvider.notifier).remove(url);

    if (ref.watch(selectedFeedProvider)?.url == url) {
      ref.read(selectedFeedProvider.notifier).state = null;
      ref.read(loadArticlesProvider.notifier).refreshArticles(LoadType.cached);
    }
  }

  static Widget removeDialog({
    required BuildContext context,
    required Function onButtonYes,
    required List<Feed> feeds,
  }) {
    return AlertDialog(
      title: SelectableText('Remove feed${feeds.length > 1 ? 's' : ''}'),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: SelectableText(
                  'The following${feeds.length > 1 ? ' ${feeds.length} ' : ' '}feed${feeds.length > 1 ? 's' : ''} will get removed:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 16.0),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                  horizontalTitleGap: 12.0,
                  dense: true,
                  leading: FutureBuilder(
                    future: fetchFavicon(url: feeds[index].url),
                    builder: (context, snapshot) {
                      return Favicon(
                        url: snapshot.data,
                        width: 24.0,
                        height: 24.0,
                      );
                    },
                  ),
                  title: SelectableText.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: feeds[index].url,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const TextSpan(text: ' – '),
                      TextSpan(
                        text: feeds[index].author,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ]),
                    maxLines: 1,
                  ),
                ),
                separatorBuilder: (context, index) => const Divider(),
                itemCount: feeds.length,
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onButtonYes();
          },
          child: const Text('Remove'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [...ref.watch(feedsProvider)];

    return ListView(
      padding: MediaQuery.of(context).size.width > ScreenSize.tabletWidth
          ? const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0)
          : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      children: [
        Text(
          'OPML file',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            ElevatedButton(
              onPressed:
                  Opml(ref: ref, context: widget.scaffoldContext).importOpml,
              child: const Text('Import'),
            ),
            const SizedBox(width: 8.0),
            OutlinedButton(
              onPressed:
                  Opml(ref: ref, context: widget.scaffoldContext).exportOpml,
              child: const Text('Export'),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        const Divider(),
        const SizedBox(height: 32.0),
        Text(
          'Add feed',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (value) {
                  setState(() => invalidURL = false);
                },
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                  hintText: 'Paste URL',
                  errorText: invalidURL ? 'Invalid URL' : null,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: controller.value.text.isEmpty ? null : _addFeed,
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 32.0),
        Consumer(
          builder: (context, ref, child) {
            var isSelecting = 0;
            for (final settingsFeed
                in ref.watch(settingsFeedsProvider).entries) {
              if (settingsFeed.value) isSelecting++;
            }

            return SizedBox(
              child: Column(
                children: [
                  if (items.isNotEmpty)
                    Card(
                      child: ListTile(
                        title: Text(
                          'Select all',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        horizontalTitleGap: 8.0,
                        leading: IconButton(
                          onPressed: () {
                            for (final settingsFeed
                                in ref.watch(settingsFeedsProvider).entries) {
                              ref.read(settingsFeedsProvider.notifier).set(
                                    settingsFeed.key,
                                    isSelecting <= 0
                                        ? true
                                        : isSelecting < items.length
                                            ? true
                                            : false,
                                  );
                            }
                          },
                          icon: Icon(
                            isSelecting <= 0
                                ? Icons.check_box_outline_blank
                                : isSelecting >= items.length
                                    ? Icons.check_box
                                    : Icons.indeterminate_check_box,
                          ),
                        ),
                        trailing: isSelecting > 0
                            ? ElevatedButton.icon(
                                label: const Text('Remove'),
                                onPressed: _removeSelected,
                                icon: const Icon(Icons.delete),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                ),
                              )
                            : null,
                        contentPadding:
                            const EdgeInsets.only(left: 4.0, right: 8.0),
                      ),
                    ),
                  ReorderableListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 48.0),
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;

                      final item = items.removeAt(oldIndex);
                      items.insert(newIndex, item);
                      ref.read(feedsProvider.notifier).state = items;
                      PrefFeeds().set(items);
                    },
                    buildDefaultDragHandles: false,
                    itemCount: items.length,
                    itemBuilder: (context, index) => FeedItem(
                      key: ValueKey(items[index].url),
                      index: index,
                      url: items[index].url,
                      isSelectingMode: isSelecting > 0,
                      scaffoldContext: widget.scaffoldContext,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
