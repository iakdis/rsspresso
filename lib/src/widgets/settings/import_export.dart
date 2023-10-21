import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/feeds_provider.dart';
import '../../providers/refresh_provider.dart';
import '../../providers/settings_feeds_provider.dart';
import '../../utils/cache.dart';
import '../../utils/favicon.dart';
import '../../utils/opml_parser.dart';
import '../../utils/preferences/preferences.dart';
import '../favicon.dart';
import '../snackbar.dart';

class Opml {
  Opml({
    required this.ref,
    required this.context,
  });

  final WidgetRef ref;
  final BuildContext context;

  Future<void> exportOpml() async {
    final subs = <Map<String, dynamic>>[];
    for (final feed in ref.watch(feedsProvider)) {
      final author = (await Cache.loadFeed(ref: ref, url: feed.url)).author!;
      subs.add({
        'text': author,
        'title': author,
        'type': 'rss',
        'xmlUrl': feed.url,
      });
    }

    final opmlOutline = {
      'opml': {
        'head': {
          'title': 'rssPresso Export',
        },
        'body': {
          'subs': subs,
        },
      },
    };
    final opmlString = OpmlParser.opmlStringify(opmlOutline);

    const fileName = 'rssPresso Export.opml';
    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select a save location:',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['opml'],
      );
      if (outputFile == null) return;

      final file = await File(outputFile).create();
      await file.writeAsString(opmlString);
    } catch (e) {
      String? outputFile = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          data: utf8.encoder.convert(opmlString),
          fileName: fileName,
        ),
      );
      if (outputFile == null) return;
    }

    if (!context.mounted) return;

    showSnackbar(
      text: 'Exported feeds',
      seconds: 4,
      context: context,
      undoAction: null, // TODO
    );
  }

  Future<void> importOpml() async {
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['opml'],
      );
    } catch (e) {
      result = await FilePicker.platform.pickFiles();
    }

    if (result == null) return;

    if (!result.files.single.path!.endsWith('opml')) {
      if (!context.mounted) return;
      showSnackbar(
        text: 'Please choose a .opml file',
        seconds: 4,
        context: context,
      );
      return;
    }

    File file = File(result.files.single.path!);
    final contents = await file.readAsString();

    final parsedOpml = OpmlParser.opmlParse(contents, onlySubs: true);
    final newFeeds = _filterNewFeeds(opml: parsedOpml);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => _importDialog(newFeeds: newFeeds),
      );
    }
  }

  List<Map<String, dynamic>> _filterNewFeeds(
      {required Map<String, dynamic> opml}) {
    final currentFeedsUrls = <String>[];
    for (final feed in ref.watch(feedsProvider)) {
      currentFeedsUrls.add(feed.url);
    }

    final parsedOpmlUrls = <String>[];
    for (final entry in opml['subs']) {
      parsedOpmlUrls.add(entry['xmlUrl']);
    }

    final newFeeds = <Map<String, dynamic>>[];
    for (final entry in opml['subs']) {
      if (!currentFeedsUrls.contains(entry['xmlUrl'])) {
        newFeeds.add(entry);
      }
    }

    return newFeeds;
  }

  void _saveImport({required List<Map<String, dynamic>> newFeeds}) async {
    for (final feed in newFeeds) {
      await PrefFeeds().addIfNotExisting(feed['xmlUrl']);
      ref.read(feedsProvider.notifier).state = PrefFeeds().get();
      ref.read(settingsFeedsProvider.notifier).set(feed['xmlUrl'], false);
    }

    if (!context.mounted) return;

    showSnackbar(
      text: 'Imported ${newFeeds.length} feed${newFeeds.length > 1 ? 's' : ''}',
      seconds: 4,
      context: context,
      undoAction: null, // TODO
    );

    ref.read(isRefreshingProvider.notifier).state = false;
  }

  Widget _importDialog({required List<Map<String, dynamic>> newFeeds}) {
    final isNotEmpty = newFeeds.isNotEmpty;

    final selected = <bool>[];
    for (var i = 0; i < newFeeds.length; i++) {
      selected.add(true);
    }

    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: const SelectableText('Import OPML file'),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        content: SizedBox(
          width: isNotEmpty ? 500 : 300,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading:
                      isNotEmpty ? null : const Icon(Icons.warning, size: 32),
                  title: SelectableText(
                    isNotEmpty
                        ? 'The following new feeds will get imported:'
                        : 'Feeds to import already exist - nothing will be changed.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (isNotEmpty) ...[
                  const SizedBox(height: 16.0),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) => ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 0.0),
                      dense: true,
                      leading: IconButton(
                        onPressed: () =>
                            setState(() => selected[index] = !selected[index]),
                        icon: Icon(
                          selected[index]
                              ? Icons.check_circle
                              : Icons.check_circle_outlined,
                        ),
                      ),
                      horizontalTitleGap: 4.0,
                      title: Row(
                        children: [
                          FutureBuilder(
                              future: Cache.loadFeed(
                                ref: ref,
                                url: newFeeds[index]['xmlUrl']!,
                              ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return Container();

                                final firstItemLink = snapshot.data!.favicon!;
                                return FutureBuilder(
                                  future: fetchFavicon(url: firstItemLink),
                                  builder: (context, snapshot) => Favicon(
                                    url: snapshot.data,
                                    width: 24.0,
                                    height: 24.0,
                                  ),
                                );
                              }),
                          const SizedBox(width: 8.0),
                          Flexible(
                            child: SelectableText.rich(
                              TextSpan(children: [
                                TextSpan(
                                  text: newFeeds[index]['xmlUrl'],
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const TextSpan(text: ' – '),
                                TextSpan(
                                  text: newFeeds[index]['text'],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ]),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: newFeeds.length,
                  ),
                  const SizedBox(height: 24.0),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isNotEmpty ? 'Cancel' : 'Okay'),
          ),
          if (isNotEmpty)
            ElevatedButton(
              onPressed: !selected.contains(true)
                  ? null
                  : () {
                      final selectedFeeds = <Map<String, dynamic>>[];
                      for (var i = 0; i < selected.length; i++) {
                        if (selected[i]) {
                          selectedFeeds.add(newFeeds[i]);
                        }
                      }

                      _saveImport(newFeeds: selectedFeeds);
                      Navigator.pop(context);
                    },
              child: const Text('Import'),
            ),
        ],
      );
    });
  }
}
