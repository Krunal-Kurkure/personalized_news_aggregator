import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleDetailScreen extends StatefulWidget {
  final String url;
  final String title;
  const ArticleDetailScreen({Key? key, required this.url, required this.title}) : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late final WebViewController _controller;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(onProgress: (p) {
        setState(() {
          progress = p / 100.0;
        });
      }))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          if (progress < 1) LinearProgressIndicator(value: progress),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}
