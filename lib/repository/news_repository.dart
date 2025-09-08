import 'package:personalized_news_aggregator/models/Articles.dart';

import '../data/local_storage.dart';
import '../services/news_api_service.dart';

class NewsRepository {
  final NewsApiService api;

  NewsRepository({required this.api});

  Future<List<Article>> getHeadlines({
    String category = '',
    String country = 'us',
    int page = 1,
    int pageSize = 20,
  }) {
    return api.fetchTopHeadlines(
        category: category, country: country, page: page, pageSize: pageSize);
  }

  Future<List<Article>> search(String query, {int page = 1, int pageSize = 20}) {
    return api.searchEverything(query: query, page: page, pageSize: pageSize);
  }

  Future<void> saveArticle(Article a) => LocalStorage.saveArticle(a);
  Future<void> removeArticle(String url) => LocalStorage.removeArticle(url);
  List<Article> getSavedArticles() => LocalStorage.getSavedArticles();
  bool isSaved(String? url) => LocalStorage.isSaved(url);
}
