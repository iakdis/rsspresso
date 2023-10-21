import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_feeds_provider.dart';
import '../../utils/cache.dart';
import '../../utils/favicon.dart';
import '../../utils/globals.dart';
import '../favicon.dart';
import '../menu.dart';
import '../snackbar.dart';
import 'feed_tab.dart';

class FeedItem extends ConsumerWidget {
  const FeedItem({
    super.key,
    required this.index,
    required this.url,
    required this.isSelectingMode,
    required this.scaffoldContext,
  });

  final int index;
  final String url;
  final bool isSelectingMode;
  final BuildContext scaffoldContext;

  void removeFeed(BuildContext context, WidgetRef ref, String url) async {
    final feed = await Cache.loadFeed(ref: ref, url: url);

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => FeedTabState.removeDialog(
        context: context,
        feeds: [feed],
        onButtonYes: () async {
          showSnackbar(
            text: 'Removed feed "${feed.author!}"',
            seconds: 4,
            context: scaffoldContext,
            undoAction: null, // TODO
          );

          FeedTabState.removeFeed(ref, url: url);
        },
      ),
    );
  }

  void select(WidgetRef ref) {
    final settingsFeeds = ref.read(settingsFeedsProvider.notifier);
    settingsFeeds.set(url, !(ref.read(settingsFeedsProvider)[url] ?? false));

    if (ref.read(settingsFeedsProvider)[url] == true) {
      settingsFeeds.set(url, true);
    } else {
      settingsFeeds.set(url, false);
    }
  }

  Widget feedItem(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: Cache.loadFeed(ref: ref, url: url),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final feed = snapshot.data!;

          final author = feed.author!;
          final firstItemLink = feed.favicon!;

          final isSelected = ref.watch(settingsFeedsProvider)[url] ?? false;

          return Column(
            children: [
              Container(
                height: 48.0,
                padding: EdgeInsets.symmetric(
                    horizontal: isSelectingMode ? 8.0 : 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelectingMode)
                      IconButton(
                        onPressed: () => select(ref),
                        icon: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.check_circle_outlined,
                        ),
                      )
                    else
                      ReorderableDragStartListener(
                        index: index,
                        child: const Icon(
                          Icons.drag_handle,
                          color: Colors.grey,
                        ),
                      ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width >
                                ScreenSize.tabletWidth
                            ? 32.0
                            : 16.0),
                    FutureBuilder(
                      future: fetchFavicon(url: firstItemLink),
                      builder: (context, snapshot) {
                        return Favicon(
                          url: snapshot.data,
                          width: 24.0,
                          height: 24.0,
                        );
                      },
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width >
                                ScreenSize.tabletWidth
                            ? 16.0
                            : 12.0),
                    Expanded(
                      child: Tooltip(
                        message: '$author – $url',
                        child: SelectableText.rich(
                          TextSpan(children: [
                            TextSpan(
                              text: author,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const TextSpan(text: ' – '),
                            TextSpan(
                              text: url,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ]),
                          maxLines: 1,
                        ),
                      ),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width >
                                ScreenSize.tabletWidth
                            ? 32.0
                            : 6.0),
                    Menu(
                      menuChildren: [
                        MenuButton(
                          onPressed: () => select(ref),
                          icon: isSelected
                              ? Icons.check_circle
                              : Icons.check_circle_outlined,
                          text: isSelected ? 'Deselect' : 'Select',
                        ),
                        // TODO Implement Edit button
                        // if (!isSelectingMode)
                        //   MenuButton(
                        //     onPressed: () {},
                        //     icon: Icons.edit,
                        //     text: 'Edit',
                        //   ),
                        if (!isSelectingMode)
                          MenuButton(
                            onPressed: () => removeFeed(context, ref, url),
                            icon: Icons.delete,
                            text: 'Remove',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 0),
            ],
          );
        }
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => feedItem(context, ref);
}
