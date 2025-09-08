import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import '../data/local_storage.dart';
import '../providers/providers.dart';
import '../widgets/article_card.dart';
import '../widgets/category_chips.dart';
import 'article_detail_screen.dart';
import 'saved_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final RefreshController _refreshController = RefreshController();
  final ScrollController _scrollController = ScrollController();
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    LocalStorage.init();
    Connectivity().onConnectivityChanged.listen((status) {
      setState(() {
        _isOffline = status == ConnectivityResult.none;
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(headlinesProvider.notifier).fetchMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final headlinesState = ref.watch(headlinesProvider);
    final repo = ref.watch(newsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Newsly'),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SavedScreen())),
            tooltip: 'Saved',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isOffline)
            Container(
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Row(
                children: [Icon(Icons.wifi_off), SizedBox(width: 8), Text('You are offline — showing saved content only')],
              ),
            ),
          SizedBox(height: 8),
          CategoryChips(),
          Expanded(
            child: headlinesState.when(
              data: (articles) {
                if (_isOffline && articles.isEmpty) {
                  // show saved
                  final saved = repo.getSavedArticles();
                  return saved.isEmpty
                      ? Center(child: Text('No content available offline.'))
                      : ListView.builder(
                          itemCount: saved.length,
                          itemBuilder: (context, idx) {
                            final a = saved[idx];
                            return ArticleCard(
                              article: a,
                              isSaved: repo.isSaved(a.url),
                              onTap: () {
                                if (a.url != null) Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailScreen(url: a.url!, title: a.title ?? 'Article')));
                              },
                              onSave: () async {
                                if (a.url != null) {
                                  await repo.removeArticle(a.url!);
                                  setState(() {});
                                }
                              },
                              onShare: () => Share.share('${a.title ?? ''}\n${a.url ?? ''}'),
                            );
                          },
                        );
                }

                return SmartRefresher(
                  controller: _refreshController,
                  onRefresh: () async {
                    await ref.read(headlinesProvider.notifier).refresh();
                    _refreshController.refreshCompleted();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final a = articles[index];
                      final saved = repo.isSaved(a.url);
                      return ArticleCard(
                        article: a,
                        isSaved: saved,
                        onTap: () {
                          if (a.url != null) Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailScreen(url: a.url!, title: a.title ?? 'Article')));
                        },
                        onSave: () async {
                          if (a.url != null) {
                            if (saved) {
                              await repo.removeArticle(a.url!);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed from saved')));
                            } else {
                              await repo.saveArticle(a);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved for later')));
                            }
                            setState(() {}); // refresh saved state
                          }
                        },
                        onShare: () {
                          Share.share('${a.title ?? ''}\n${a.url ?? ''}');
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 12),
                    Text('Failed to load headlines', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(e.toString(), textAlign: TextAlign.center),
                    SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(headlinesProvider.notifier).fetchInitial(),
                      child: Text('Retry'),
                    )
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
