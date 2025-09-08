import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:personalized_news_aggregator/models/Articles.dart';

class NewsApiService {
  final Dio _dio;

  NewsApiService([Dio? dio])
      : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://newsapi.org/v2/'));

  String get _apiKey => dotenv.env['NEWS_API_KEY'] ?? '';

  Future<List<Article>> fetchTopHeadlines({
    String category = '',
    String country = 'us',
    int page = 1,
    int pageSize = 20,
    String? q,
  }) async {
    final params = <String, dynamic>{
      'apiKey': _apiKey,
      'country': country,
      'page': page,
      'pageSize': pageSize,
    };
    if (category.isNotEmpty) params['category'] = category;
    if (q != null && q.isNotEmpty) params['q'] = q;

    final resp = await _dio.get('top-headlines', queryParameters: params);
    if (resp.statusCode == 200) {
      final data = resp.data;
      final List<dynamic> list = data['articles'] as List<dynamic>;
      return list.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('News API error: ${resp.statusCode}');
    }
  }

  Future<List<Article>> searchEverything({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, dynamic>{
      'apiKey': _apiKey,
      'q': query,
      'page': page,
      'pageSize': pageSize,
    };
    final resp = await _dio.get('everything', queryParameters: params);
    if (resp.statusCode == 200) {
      final List<dynamic> list = resp.data['articles'] as List<dynamic>;
      return list.map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('News API search error: ${resp.statusCode}');
    }
  }
}
