// Simple navigation helper to replace auto_route
// This file provides basic navigation without the complexity of auto_route

import 'package:flutter/material.dart';
import 'package:inshort_clone/model/news_model.dart';
import 'package:inshort_clone/view/feed_screen/feed.dart';
import 'package:inshort_clone/view/settings_screen/settings.dart';
import 'package:inshort_clone/view/web_screen/web.dart';

class SimpleRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static NavigatorState get navigator => navigatorKey.currentState!;
  
  // Route names
  static const String feedScreen = '/feed';
  static const String settingsScreen = '/settings';
  static const String webScreen = '/web';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case feedScreen:
        final args = settings.arguments as FeedScreenArguments?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => FeedScreen(
              articalIndex: args.articalIndex,
              articals: args.articals,
              isFromSearch: args.isFromSearch,
            ),
          );
        }
        return _errorRoute();
        
      case settingsScreen:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
        
      case webScreen:
        final args = settings.arguments as WebViewArguments?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => WebScreen(
              url: args.url,
              isFromBottom: args.isFromBottom,
            ),
          );
        }
        return _errorRoute();
        
      default:
        return _errorRoute();
    }
  }
  
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }
}

// Argument classes
class FeedScreenArguments {
  final int articalIndex;
  final List<Articles> articals;
  final bool isFromSearch;
  
  FeedScreenArguments({
    required this.articalIndex,
    required this.articals,
    required this.isFromSearch,
  });
}

class WebViewArguments {
  final String url;
  final bool isFromBottom;
  
  WebViewArguments({
    required this.url,
    required this.isFromBottom,
  });
}

class ExpandedImageViewArguments {
  final String image;
  
  ExpandedImageViewArguments({required this.image});
}
