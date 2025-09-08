import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personalized_news_aggregator/models/Articles.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final bool isSaved;

  const ArticleCard({
    Key? key,
    required this.article,
    required this.onTap,
    required this.onSave,
    required this.onShare,
    this.isSaved = false,
  }) : super(key: key);

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    try {
      return DateFormat.yMMMd().add_jm().format(dt);
    } catch (_) {
      return dt.toIso8601String();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(14)),
              child: (article.urlToImage != null)
                  ? CachedNetworkImage(
                      imageUrl: article.urlToImage!,
                      width: 120,
                      height: 110,
                      fit: BoxFit.cover,
                      placeholder: (c, s) => Container(width: 120, height: 110, color: Colors.grey[200]),
                      errorWidget: (c, s, e) => Container(width: 120, height: 110, color: Colors.grey[200], child: Icon(Icons.broken_image)),
                    )
                  : Container(width: 120, height: 110, color: Colors.grey[200], child: Icon(Icons.image)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.sourceName != null)
                      Text(article.sourceName!, style: TextStyle(fontSize: 12, color: Colors.indigo)),
                    SizedBox(height: 6),
                    Text(article.title ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDate(article.publishedAt), style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        Row(children: [
                          IconButton(
                            icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                            onPressed: onSave,
                            splashRadius: 20,
                          ),
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: onShare,
                            splashRadius: 20,
                          ),
                        ]),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
