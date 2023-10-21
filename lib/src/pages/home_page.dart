import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rssPresso/src/utils/globals.dart';

import '../providers/load_articles_provider.dart';
import '../providers/search_provider.dart';
import '../providers/view_provider.dart';
import '../widgets/card/card_view.dart';
import '../widgets/card/card_view_mobile.dart';
import '../widgets/compact/compact_view.dart';
import '../widgets/compact/compact_view_mobile.dart';
import '../widgets/list/list_view.dart';
import '../widgets/magazine/magazine_view.dart';
import '../models/filter.dart';
import '../models/home_view.dart';
import '../providers/filter_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (ref.watch(viewProvider) == null) {
        ref.watch(viewProvider.notifier).state =
            MediaQuery.of(context).size.width <= ScreenSize.mobileWidth
                ? HomeView.cardViewMobile
                : HomeView.cardView;
      }
    });
  }

  Widget view(HomeView view) {
    switch (view) {
      // Desktop
      case HomeView.cardView:
        return const ArticleCardView();
      case HomeView.listView:
        return const ArticleListView();
      case HomeView.magazineView:
        return const ArticleMagazineView();
      case HomeView.compactView:
        return const ArticleCompactView();

      // Mobile
      case HomeView.cardViewMobile:
        return const ArticleCardViewMobile();
      case HomeView.compactViewMobile:
        return const ArticleCompactViewMobile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ref.watch(loadArticlesProvider),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Center(
              child: SelectableText(
                'No feeds to display. Enjoy the silence.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
        }

        return Stack(
          children: [
            Consumer(
              builder: (context, ref, child) {
                if (ref.watch(searchedArticlesProvider).isNotEmpty) {
                  return view(ref.watch(viewProvider)!);
                } else if (snapshot.connectionState !=
                        ConnectionState.waiting &&
                    ref.watch(searchedArticlesProvider).isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Center(
                      child: SelectableText(
                        ref.watch(filterProvider) == Filter.allArticles
                            ? 'No articles to be shown.'
                            : 'No articles to be shown. Try removing any active filters.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  );
                }

                return Container();
              },
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const LinearProgressIndicator(minHeight: 6.0),
          ],
        );
      },
    );
  }
}
