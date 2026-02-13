// Package imports:
import 'package:bloc/bloc.dart';

// Project imports:
import 'package:inshort_clone/bloc/feed/news_feed_event.dart';
import 'package:inshort_clone/bloc/feed/news_feed_state.dart';
import 'package:inshort_clone/services/news/news_service.dart';

class NewsFeedBloc extends Bloc<NewsFeedEvent, NewsFeedState> {
  final NewsFeedRepository repository;
  NewsFeedBloc({required this.repository}) : super(NewsFeedInitialState()) {
    on<FetchNewsByCategoryEvent>((event, emit) async {
      emit(NewsFeedLoadingState());
      try {
        final news = await repository.getNewsByCategory(event.category);
        emit(NewsFeedLoadedState(news: news));
      } catch (e) {
        emit(NewsFeedErrorState(message: e.toString()));
      }
    });

    on<FetchNewsByTopicEvent>((event, emit) async {
      emit(NewsFeedLoadingState());
      try {
        final news = await repository.getNewsByTopic(event.topic);
        emit(NewsFeedLoadedState(news: news));
      } catch (e) {
        emit(NewsFeedErrorState(message: e.toString()));
      }
    });

    on<FetchNewsFromLocalStorageEvent>((event, emit) async {
      emit(NewsFeedLoadingState());
      try {
        final news = repository.getNewsFromLocalStorage(event.box);
        emit(NewsFeedLoadedState(news: news));
      } catch (e) {
        emit(NewsFeedErrorState(message: e.toString()));
      }
    });
  }
}
