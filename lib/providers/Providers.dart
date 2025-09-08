import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personalized_news_aggregator/models/Articles.dart';

import '../repository/news_repository.dart';
import '../services/news_api_service.dart';

// Repository provider
final newsApiProvider = Provider((ref) => NewsApiService());
final newsRepositoryProvider =
    Provider((ref) => NewsRepository(api: ref.watch(newsApiProvider)));

// UI state: selected category
final categoryProvider = StateProvider<String>((ref) => 'general');

// Headlines AsyncNotifier (simple)
final headlinesProvider =
    StateNotifierProvider<HeadlinesNotifier, AsyncValue<List<Article>>>(
  (ref) {
    final repo = ref.watch(newsRepositoryProvider);
    final category = ref.watch(categoryProvider);
    return HeadlinesNotifier(repo, category);
  },
);

class HeadlinesNotifier extends StateNotifier<AsyncValue<List<Article>>> {
  final NewsRepository repo;
  final String category;
  int _page = 1;
  bool _hasMore = true;
  List<Article> _items = [];

  HeadlinesNotifier(this.repo, this.category)
      : super(const AsyncValue.loading()) {
    fetchInitial();
  }

  Future<void> fetchInitial() async {
    state = const AsyncValue.loading();
    _page = 1;
    _hasMore = true;
    _items = [];
    try {
      final list = await repo.getHeadlines(
          category: category, page: _page, pageSize: 20);
      _items = list;
      state = AsyncValue.data(_items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await fetchInitial();
  }

  Future<void> fetchMore() async {
    if (!_hasMore) return;
    _page++;
    try {
      final list = await repo.getHeadlines(
          category: category, page: _page, pageSize: 20);
      if (list.isEmpty) _hasMore = false;
      _items.addAll(list);
      state = AsyncValue.data(_items);
    } catch (e, st) {
      // keep existing state but show error
      state = AsyncValue.error(e, st);
    }
  }
}

// Saved articles provider
final savedArticlesProvider = Provider<List<Article>>((ref) {
  final repo = ref.watch(newsRepositoryProvider);
  return repo.getSavedArticles();
});
