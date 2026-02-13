// Package imports:
import 'package:bloc/bloc.dart';

// Project imports:
import 'package:inshort_clone/services/news/news_service.dart';
import 'search_feed_event.dart';
import 'search_feed_state.dart';

class SearchFeedBloc extends Bloc<SearchFeedEvent, SearchFeedState> {
  final NewsFeedRepository repository;
  SearchFeedBloc({required this.repository}) : super(SearchFeedInitialState()) {
    on<FetchNewsBySearchQueryEvent>((event, emit) async {
      emit(SearchFeedLoadingState());
      try {
        final news = await repository.getNewsBySearchQuery(event.query);
        emit(SearchFeedLoadedState(news: news));
      } catch (e) {
        emit(SearchFeedErrorState(message: e.toString()));
      }
    });
  }
}
