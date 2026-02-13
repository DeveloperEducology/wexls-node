// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:inshort_clone/view/app_base/app_base.dart';
import 'package:inshort_clone/view/discover_screen/discover.dart';

class FeedProvider extends ChangeNotifier {
  String _appBarTitle = "Discover";
  int _activeCategory = 1;
  bool _hasDataLoaded = false;
  bool _searchAppBarVisible = true;
  bool _appBarVisible = false;
  bool _watermarkVisible = false;
  bool _feedBottomActionbarVisible = false;
  int _curentArticalIndex = 0;
  PageController? _feedPageController;
  PageController? _screenController;
  final List<Widget> _baseScreen = [
    const DiscoverScreen(),
    const BuildNewsScreen(),
  ];
  String _newsURL = "https://google.com/";
  bool _webviwAdded = false;
  final List<String> _lastGetRequest = [];

  //

  bool get gethasDataLoaded => _hasDataLoaded;

  int get getActiveCategory => _activeCategory;

  String get getAppBarTitle => _appBarTitle;

  bool get getSearchAppBarVisible => _searchAppBarVisible;

  bool get getAppBarVisible => _appBarVisible;

  bool get getWatermarkVisible => _watermarkVisible;

  bool get getFeedBottomActionbarVisible => _feedBottomActionbarVisible;

  int get getCurentArticalIndex => _curentArticalIndex;

  PageController? get getfeedPageController => _feedPageController;

  PageController? get getScreenController => _screenController;

  List<Widget> get getBaseScreenList => _baseScreen;

  String get getNewsURL => _newsURL;

  List<String> get getLastGetRequest => _lastGetRequest;

  bool get webviwAdded => _webviwAdded;

  ///

  void setActiveCategory(int activeCategory) {
    _activeCategory = activeCategory;
    notifyListeners();
  }

  void setAppBarTitle(String appBarTitle) {
    _appBarTitle = appBarTitle;
    notifyListeners();
  }

  void setDataLoaded(bool status) {
    _hasDataLoaded = status;
    notifyListeners();
  }

  void setSearchAppBarVisible(bool searchAppBarVisible) {
    _searchAppBarVisible = searchAppBarVisible;
    notifyListeners();
  }

  void setAppBarVisible(bool appBarVisible) {
    _appBarVisible = appBarVisible;
    notifyListeners();
  }

  void setWatermarkVisible(bool visible) {
    _watermarkVisible = visible;
    notifyListeners();
  }

  void setFeedBottomActionbarVisible(bool feedBottomActionbarVisible) {
    _feedBottomActionbarVisible = feedBottomActionbarVisible;
    notifyListeners();
  }

  void setCurentArticalIndex(int curentArticalIndex) {
    _curentArticalIndex = curentArticalIndex;
    notifyListeners();
  }

  void setfeedPageController(PageController pageController) {
    _feedPageController = pageController;
    notifyListeners();
  }

  void setScreenController(PageController pageController) {
    _screenController = pageController;
    notifyListeners();
  }

  void addWebScren(Widget widget) {
    _baseScreen.add(widget);
    notifyListeners();
  }

  void setNewsURL(String newsURL) {
    _newsURL = newsURL;
    notifyListeners();
  }

  void setWebViewAdded() {
    _webviwAdded = true;
    notifyListeners();
  }

  void setLastGetRequest(String request, String value) {
    _lastGetRequest.clear();
    _lastGetRequest.add(request);
    _lastGetRequest.add(value);
    notifyListeners();
  }
}
