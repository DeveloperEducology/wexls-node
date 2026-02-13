// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:inshort_clone/app/dio/dio.dart';
import 'package:inshort_clone/controller/provider.dart';
import 'package:inshort_clone/model/news_model.dart';
import 'package:inshort_clone/services/news/offline_service.dart';

abstract class NewsFeedRepository {
  Future<List<Articles>> getNewsByTopic(String topic);

  Future<List<Articles>> getNewsByCategory(String category);

  Future<List<Articles>> getNewsBySearchQuery(String query);

  List<Articles> getNewsFromLocalStorage(String box);
}

class NewsFeedRepositoryImpl implements NewsFeedRepository {
  final BuildContext context;
  NewsFeedRepositoryImpl(this.context);

  @override
  Future<List<Articles>> getNewsByTopic(String topic) async {
    final String url = "everything?q=$topic";
    final provider = Provider.of<FeedProvider>(context, listen: false);

    provider.setDataLoaded(false);
    provider.setLastGetRequest("getNewsByTopic", topic);

    Response response = await GetDio.getDio().get(url);
    if (response.statusCode == 200) {
      List<Articles> articles = NewsModel.fromJson(response.data).articles ?? [];

      provider.setDataLoaded(true);
      addArticlesToUnreads(articles);

      return articles;
    } else {
      provider.setDataLoaded(true);
      throw Exception();
    }
  }

  @override
  Future<List<Articles>> getNewsByCategory(String category) async {
    final String url = "api/curated-feed";
    final provider = Provider.of<FeedProvider>(context, listen: false);

    provider.setDataLoaded(false);
    provider.setLastGetRequest("getNewsByCategory", category);

    try {
      Response response = await GetDio.getDio().get(url);
      if (response.statusCode == 200) {
        // Transform the custom API response to NewsAPI format
        final data = response.data;
        
        if (data['status'] == 'success' && data['posts'] != null) {
          List<dynamic> posts = data['posts'];
          
          // Transform posts to articles format
          List<Articles> articles = posts.map<Articles>((post) {
            return Articles(
              sourceName: post['sourceName'] ?? post['source'] ?? 'Unknown',
              author: post['sourceName'] ?? post['source'],
              title: post['title'] ?? '',
              description: post['summary'] ?? post['text'] ?? '',
              url: post['url'] ?? '',
              urlToImage: post['imageUrl'],
              publishedAt: post['publishedAt'] ?? post['createdAt'],
              content: post['text'] ?? post['summary'] ?? '',
            );
          }).toList();

          provider.setDataLoaded(true);
          addArticlesToUnreads(articles);

          return articles;
        } else {
          provider.setDataLoaded(true);
          throw Exception('Invalid response format');
        }
      } else {
        provider.setDataLoaded(true);
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      provider.setDataLoaded(true);
      // ignore: avoid_print
      print('Error fetching news: $e');
      rethrow;
    }
  }

  @override
  Future<List<Articles>> getNewsBySearchQuery(String query) async {
    final provider = Provider.of<FeedProvider>(context, listen: false);

    provider.setDataLoaded(false);

    final String url = "everything?q=$query";

    Response response = await GetDio.getDio().get(url);
    if (response.statusCode == 200) {
      List<Articles> articles = NewsModel.fromJson(response.data).articles ?? [];

      addArticlesToUnreads(articles);
      provider.setDataLoaded(true);
      return articles;
    } else {
      provider.setDataLoaded(true);
      throw Exception();
    }
  }

  @override
  List<Articles> getNewsFromLocalStorage(String fromBox) {
    List<Articles> articles = [];
    final Box<Articles> hiveBox = Hive.box<Articles>(fromBox);
    final provider = Provider.of<FeedProvider>(context, listen: false);

    provider.setLastGetRequest("getNewsFromLocalStorage", fromBox);

    if (hiveBox.length > 0) {
      for (int i = 0; i < hiveBox.length; i++) {
        Articles? article = hiveBox.getAt(i);
        if (article != null) {
          articles.add(article);
        }
      }
      provider.setDataLoaded(true);

      return articles;
    } else {
      provider.setDataLoaded(true);
      return [];
    }
  }
}
