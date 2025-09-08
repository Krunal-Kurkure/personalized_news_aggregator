class Article {
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  final String? author;
  final DateTime? publishedAt;
  final String? content;
  final String? sourceName;

  Article({
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.author,
    this.publishedAt,
    this.content,
    this.sourceName,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
      urlToImage: json['urlToImage'] as String?,
      author: json['author'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
      content: json['content'] as String?,
      sourceName: json['source'] != null ? (json['source']['name'] as String?) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'author': author,
      'publishedAt': publishedAt?.toIso8601String(),
      'content': content,
      'source': {'name': sourceName},
    };
  }
}
