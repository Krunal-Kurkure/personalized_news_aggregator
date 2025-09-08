import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:personalized_news_aggregator/models/Articles.dart';

class LocalStorage {
  static const savedBox = 'saved_articles';
  static bool _initialized = false;

  static Future<void> init() async {
    if (!_initialized) {
      await Hive.initFlutter();
      await Hive.openBox<String>(savedBox);
      _initialized = true;
    }
  }

  static Future<void> saveArticle(Article a) async {
    final box = Hive.box<String>(savedBox);
    if (a.url != null) {
      box.put(a.url!, jsonEncode(a.toJson()));
    }
  }

  static Future<void> removeArticle(String url) async {
    final box = Hive.box<String>(savedBox);
    await box.delete(url);
  }

  static List<Article> getSavedArticles() {
    final box = Hive.box<String>(savedBox);
    return box.values.map((s) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        return Article.fromJson(map);
      } catch (_) {
        return Article(title: 'Invalid', description: 'Corrupt saved article');
      }
    }).toList();
  }

  static bool isSaved(String? url) {
    if (url == null) return false;
    final box = Hive.box<String>(savedBox);
    return box.containsKey(url);
  }
}
