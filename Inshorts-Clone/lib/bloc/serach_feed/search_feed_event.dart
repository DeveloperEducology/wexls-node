// Flutter imports:

// Package imports:
import 'package:equatable/equatable.dart';

abstract class SearchFeedEvent extends Equatable {}

class FetchNewsBySearchQueryEvent extends SearchFeedEvent {
  final String query;
  FetchNewsBySearchQueryEvent({required this.query});

  @override
  List<Object> get props => [query];
}
