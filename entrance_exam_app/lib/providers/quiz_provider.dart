import 'dart:async';
import 'package:flutter/material.dart';
import '../models/data_models.dart';

enum QuizMode { practice, exam }

class QuizProvider extends ChangeNotifier {
  List<Question> _questions = Quiz.sampleData;
  List<Question> get questions => _questions;

  void loadQuestions(List<Question> newQuestions) {
    _questions = newQuestions;
    // Don't notify yet, wait for startQuiz
  }

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  Map<int, int> _selectedAnswers = {}; // QuestionIndex -> OptionIndex
  Map<int, int> get selectedAnswers => _selectedAnswers;
  
  Set<int> _checkedQuestions = {}; // For practice mode, to track which questions have been checked
  Set<int> get checkedQuestions => _checkedQuestions;

  Set<int> _markedForReview = {};
  Set<int> get markedForReview => _markedForReview;

  QuizMode _mode = QuizMode.practice;
  QuizMode get mode => _mode;

  Timer? _timer;
  int _secondsRemaining = 600;
  int get secondsRemaining => _secondsRemaining;
 
  DateTime? _startTime;
  DateTime? get startTime => _startTime;
  int get elapsedSeconds => _startTime != null ? DateTime.now().difference(_startTime!).inSeconds : 0;

  bool _isFinished = false;

  int _quizDurationSeconds = 600;

  void startQuiz(QuizMode mode, {int durationSeconds = 600}) {
    _mode = mode;
    _currentIndex = 0;
    _selectedAnswers = {};
    _checkedQuestions = {};
    _markedForReview = {};
    _currentStreak = 0;
    _isFinished = false;
    _startTime = DateTime.now();
    _quizDurationSeconds = durationSeconds;
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_mode == QuizMode.exam) {
       _secondsRemaining = _quizDurationSeconds; 
    }
    
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_mode == QuizMode.exam) {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          submitQuiz();
        }
      }
      // In practice mode, we rely on elapsedSeconds getter which uses startTime diff
      notifyListeners();
    });
  }

  void selectAnswer(int optionIndex) {
    if (_isFinished) return;
    // In practice mode, if already checked, don't allow changing
    if (_mode == QuizMode.practice && _checkedQuestions.contains(_currentIndex)) return;

    _selectedAnswers[_currentIndex] = optionIndex;
    notifyListeners();
  }

  void toggleMarkForReview() {
    if (_markedForReview.contains(_currentIndex)) {
      _markedForReview.remove(_currentIndex);
    } else {
      _markedForReview.add(_currentIndex);
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void prevQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void jumpToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void submitQuiz() {
    _timer?.cancel();
    _isFinished = true;
    notifyListeners();
  }
  
  int get score {
    int s = 0;
    for (int i = 0; i < _questions.length; i++) {
        if (_selectedAnswers[i] == _questions[i].correctOptionIndex) {
            s++;
        }
    }
    return s;
  }
  
  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  void checkAnswer() {
    if (_mode == QuizMode.practice) {
      _checkedQuestions.add(_currentIndex);
      
      // Update Streak
      bool isCorrect = _selectedAnswers[_currentIndex] == _questions[_currentIndex].correctOptionIndex;
      if (isCorrect) {
        _currentStreak++;
      } else {
        _currentStreak = 0;
      }
      
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
