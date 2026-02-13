// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:inshort_clone/controller/provider.dart';

class WebScreen extends StatefulWidget {
  final String url;
  final bool isFromBottom;
  final PageController? pageController;

  const WebScreen(
      {super.key, required this.url, required this.isFromBottom, this.pageController});

  @override
  _WebScreenState createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  bool loading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              loading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(FeatherIcons.x),
          onPressed: () {
            if (widget.isFromBottom) {
              if (widget.pageController != null && widget.pageController!.hasClients) {
                widget.pageController!.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeIn,
                );
              }
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(FeatherIcons.rotateCw),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          loading
              ? const SizedBox(height: 3, child: LinearProgressIndicator())
              : Container(),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}
