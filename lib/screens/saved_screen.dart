import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/article_card.dart';
import 'article_detail_screen.dart';
import 'package:share_plus/share_plus.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(newsRepositoryProvider);
    final saved = repo.getSavedArticles();

    return Scaffold(
      appBar: AppBar(title: Text('Saved Articles')),
      body: saved.isEmpty
          ? Center(child: Text('No saved articles yet.'))
          : ListView.builder(
              itemCount: saved.length,
              itemBuilder: (context, idx) {
                final a = saved[idx];
                return ArticleCard(
                  article: a,
                  isSaved: repo.isSaved(a.url),
                  onTap: () {
                    if (a.url != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleDetailScreen(url: a.url!, title: a.title ?? 'Article')));
                    }
                  },
                  onSave: () async {
                    if (a.url != null) {
                      await repo.removeArticle(a.url!);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed from saved')));
                      ref.invalidate(savedArticlesProvider);
                    }
                  },
                  onShare: () {
                    Share.share('${a.title ?? ''}\n${a.url ?? ''}');
                  },
                );
              },
            ),
    );
  }
}
