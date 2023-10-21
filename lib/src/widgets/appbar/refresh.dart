import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/load_articles_provider.dart';
import '../../providers/refresh_provider.dart';

class RefreshButton extends ConsumerWidget {
  const RefreshButton({Key? key}) : super(key: key);

  static void refresh({required WidgetRef ref}) {
    ref.read(isRefreshingProvider.notifier).state = true;
    ref.read(loadArticlesProvider.notifier).refreshArticles(LoadType.online);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Refresh',
      onPressed:
          ref.watch(isRefreshingProvider) ? null : () => refresh(ref: ref),
      icon: const Icon(Icons.refresh),
    );
  }
}
