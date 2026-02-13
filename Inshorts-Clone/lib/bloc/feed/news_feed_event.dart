// Flutter imports:

// Package imports:
import 'package:equatable/equatable.dart';

abstract class NewsFeedEvent extends Equatable {}

class FetchNewsByCategoryEvent extends NewsFeedEvent {
  final String category;
  FetchNewsByCategoryEvent({required this.category});

  @override
  List<Object> get props => [category];
}

class FetchNewsByTopicEvent extends NewsFeedEvent {
  final String topic;
  FetchNewsByTopicEvent({required this.topic});

  @override
  List<Object> get props => [topic];
}

class FetchNewsFromLocalStorageEvent extends NewsFeedEvent {
  final String box;
  FetchNewsFromLocalStorageEvent({required this.box});

  @override
  List<Object> get props => [box];
}
