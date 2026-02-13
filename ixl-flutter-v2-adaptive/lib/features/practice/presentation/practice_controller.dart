import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../domain/models.dart';
import 'dart:convert';


class PracticeState {
  final QuestionModel? currentQuestion;
  final int questionsAnswered;
  final int smartScore;
  final Duration elapsedTime;
  final bool isChecked;
  final bool isCorrect;
  final String? userAnswer;
  final int? selectedOption;
  final List<String>? currentSortedItems;
  final Map<String, String>? currentDragAssignments; // ItemId -> GroupId
  final Map<String, String>? currentFillInBlanks; // InputID -> UserValue
  // Four Pics One Word
  final List<String>? jumbledLetters; // The letters available to pick
  final List<String?>? currentWordInput; // The slots for the answer
  final bool isLoading;
  final int streak;
  final int correctAnswers;
  final String? activeInputId;

  PracticeState({
    this.currentQuestion,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,
    this.smartScore = 0,
    this.elapsedTime = Duration.zero,
    this.isChecked = false,
    this.isCorrect = false,
    this.userAnswer,
    this.selectedOption,
    this.currentSortedItems,
    this.currentDragAssignments,
    this.currentFillInBlanks,
    this.jumbledLetters,
    this.currentWordInput,
    this.isLoading = true,
    this.streak = 0,
    this.activeInputId,
  });

  PracticeState copyWith({
    QuestionModel? currentQuestion,
    int? questionsAnswered,
    int? correctAnswers,
    int? smartScore,
    Duration? elapsedTime,
    bool? isChecked,
    bool? isCorrect,
    String? userAnswer,
    int? selectedOption,
    List<String>? currentSortedItems,
    Map<String, String>? currentDragAssignments,
    Map<String, String>? currentFillInBlanks,
    List<String>? jumbledLetters,
    List<String?>? currentWordInput,
    bool? isLoading,
    int? streak,
    String? activeInputId,
  }) {
    return PracticeState(
      currentQuestion: currentQuestion ?? this.currentQuestion,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      smartScore: smartScore ?? this.smartScore,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isChecked: isChecked ?? this.isChecked,
      isCorrect: isCorrect ?? this.isCorrect,
      userAnswer: userAnswer ?? this.userAnswer,
      selectedOption: selectedOption ?? this.selectedOption,
      currentSortedItems: currentSortedItems ?? this.currentSortedItems,
      currentDragAssignments: currentDragAssignments ?? this.currentDragAssignments,
      currentFillInBlanks: currentFillInBlanks ?? this.currentFillInBlanks,
      jumbledLetters: jumbledLetters ?? this.jumbledLetters,
      currentWordInput: currentWordInput ?? this.currentWordInput,
      isLoading: isLoading ?? this.isLoading,
      streak: streak ?? this.streak,
      activeInputId: activeInputId ?? this.activeInputId,
    );
  }
}

class PracticeController extends StateNotifier<PracticeState> {
  Timer? _timer;
  List<QuestionModel> _questions = [];
  final Random _rnd = Random();
  final String skillId;

  PracticeController(this.skillId) : super(PracticeState()) {
    _init();
  }

  static const int _pageSize = 10;
  int _currentOffset = 0;
  bool _hasMoreQuestions = true;
  bool _isFetchingMore = false;
  final Set<String> _seenIds = {};

  Future<void> _init() async {
    _startTimer();
    
    // Fetch from Supabase Filtering by SkillID
    state = state.copyWith(isLoading: true);
    final questions = await SupabaseService().fetchQuestions(
      microSkillId: skillId, 
      limit: _pageSize, 
      offset: _currentOffset
    );
     
    if (questions.isNotEmpty) {
      _questions = questions;
      _currentOffset += questions.length;
      if (questions.length < _pageSize) _hasMoreQuestions = false;
    } else {
      debugPrint("Warning: No questions from Supabase for skill $skillId.");
      _questions = []; 
    }
    
    _loadNextQuestion();
    state = state.copyWith(isLoading: false);
  }

  Future<void> _fetchMoreQuestions() async {
    if (_isFetchingMore || !_hasMoreQuestions) return;
    
    _isFetchingMore = true;
    try {
      final moreQuestions = await SupabaseService().fetchQuestions(
        microSkillId: skillId,
        limit: _pageSize,
        offset: _currentOffset
      );
      
      if (moreQuestions.isNotEmpty) {
        // Filter out any duplicates if they somehow exist (though offset should prevent this)
        final newQuestions = moreQuestions.where((q) => !_questions.any((existing) => existing.id == q.id)).toList();
        _questions.addAll(newQuestions);
        _currentOffset += moreQuestions.length; // Use raw count from DB for offset
        
        if (moreQuestions.length < _pageSize) {
          _hasMoreQuestions = false;
        }
      } else {
        _hasMoreQuestions = false;
      }
    } catch (e) {
      debugPrint("Error fetching more questions: $e");
    } finally {
      _isFetchingMore = false;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        state = state.copyWith(elapsedTime: Duration(seconds: timer.tick));
      }
    });
  }

  void _loadNextQuestion() {
    QuestionModel? nextQ;
    
    if (_questions.isNotEmpty) {
       // Filter out seen questions to avoid repeats
       final available = _questions.where((q) => !_seenIds.contains(q.id)).toList();
       
       // Check if we need to fetch more (if we have fewer than 3 available and DB has more)
       if (available.length < 3 && _hasMoreQuestions && !_isFetchingMore) {
          _fetchMoreQuestions();
       }

       if (available.isNotEmpty) {
         // ADAPTIVE SELECTION
         // Filter by difficulty based on SmartScore
         Difficulty targetDiff = Difficulty.easy;
         if (state.smartScore >= 80) targetDiff = Difficulty.hard;
         else if (state.smartScore >= 50) targetDiff = Difficulty.medium;
         
         // Try to find questions of target difficulty
         var candidates = available.where((q) => q.difficulty == targetDiff).toList();
         if (candidates.isEmpty) {
            // Fallback: broaden search
            if (targetDiff == Difficulty.hard) {
               candidates = available.where((q) => q.difficulty == Difficulty.medium).toList();
            }
            if (candidates.isEmpty) {
               candidates = available; // Any
            }
         }
         
         nextQ = candidates[_rnd.nextInt(candidates.length)];
         _seenIds.add(nextQ.id); // Mark as seen
       } else {
         nextQ = null; // No more questions
       }
    } else {
       // STRICT DB MODE: No fallback to MockData
       nextQ = null;
    }
    
    // Reset into NEW state (preserving session stats)
    List<String>? initialSortItems;
    Map<String, String>? initialDragAssignments;

    if (nextQ != null) {
      if (nextQ.type == QuestionType.sorting) {
         // Shuffle for display
         initialSortItems = List.from(nextQ.options)..shuffle();
      } else if (nextQ.type == QuestionType.dragAndDrop) {
         initialDragAssignments = {};
      } else if (nextQ.type == QuestionType.fillInTheBlank) {
        // Initialize empty map for inputs
      } else if (nextQ.type == QuestionType.fourPicsOneWord) {
         // Prepare Jumbled Letters
         final answer = nextQ.correctAnswerText?.toUpperCase() ?? "";
         final List<String> letters = answer.split('');
         // Add some noise letters
         final noiseCount = 12 - letters.length; // Standard 12 grid usually
         if (noiseCount > 0) {
            const alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            for(int i=0; i<noiseCount; i++) {
               letters.add(alpha[_rnd.nextInt(alpha.length)]);
            }
         }
         letters.shuffle();
         // TODO: We need to store these letters in state
      }
    }

    state = PracticeState(
      currentQuestion: nextQ, // Can be null
      questionsAnswered: state.questionsAnswered,
      smartScore: state.smartScore,
      elapsedTime: state.elapsedTime,
      isLoading: false,
      isChecked: false,
      isCorrect: false,
      userAnswer: null,
      selectedOption: null,
      currentSortedItems: initialSortItems,
      currentDragAssignments: initialDragAssignments,

      currentFillInBlanks: nextQ != null && nextQ.type == QuestionType.fillInTheBlank ? {} : null,
      jumbledLetters: nextQ != null && nextQ.type == QuestionType.fourPicsOneWord 
          ? _generateJumbledLetters(nextQ.correctAnswerText) 
          : null,
      currentWordInput: nextQ != null && nextQ.type == QuestionType.fourPicsOneWord
          ? List<String?>.filled(nextQ.correctAnswerText?.length ?? 0, null)
          : null,
      activeInputId: null,
    );
  }

  List<String> _generateJumbledLetters(String? answer) {
    if (answer == null) return [];
    final upper = answer.toUpperCase();
    final List<String> letters = upper.split('');
    // Fill up to 12 with random
    while (letters.length < 12) {
       letters.add(String.fromCharCode(65 + _rnd.nextInt(26)));
    }
    letters.shuffle();
    return letters;
  }

  void setTextInput(String text) {
    state = state.copyWith(userAnswer: text);
  }

  void setActiveInput(String? id) {
    state = state.copyWith(activeInputId: id);
  }

  void appendDigit(String digit) {
    final activeId = state.activeInputId;
    if (activeId == null) return;

    if (activeId == '__main_text_input__') {
      final current = state.userAnswer ?? "";
      setTextInput(current + digit);
    } else {
      // Fill in blank input
      final current = state.currentFillInBlanks?[activeId] ?? "";
      updateFillInBlank(activeId, current + digit);
    }
  }

  void backspace() {
    final activeId = state.activeInputId;
    if (activeId == null) return;

    if (activeId == '__main_text_input__') {
      final current = state.userAnswer ?? "";
      if (current.isNotEmpty) {
        setTextInput(current.substring(0, current.length - 1));
      }
    } else {
      final current = state.currentFillInBlanks?[activeId] ?? "";
      if (current.isNotEmpty) {
        updateFillInBlank(activeId, current.substring(0, current.length - 1));
      }
    }
  }

  void selectOption(int index) {
    state = state.copyWith(selectedOption: index);
  }
  
  void reorderItems(int oldIndex, int newIndex) {
    if (state.currentSortedItems == null) return;
    
    final items = List<String>.from(state.currentSortedItems!);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    
    state = state.copyWith(currentSortedItems: items);
  }

  void assignDragItem(String itemId, String? groupId) {
    if (state.currentDragAssignments == null) return;
    
    final newAssignments = Map<String, String>.from(state.currentDragAssignments!);
    if (groupId == null) {
      newAssignments.remove(itemId);
    } else {
      newAssignments[itemId] = groupId;
    }
    state = state.copyWith(currentDragAssignments: newAssignments);
  }

  void updateFillInBlank(String id, String value) {
    if (state.currentFillInBlanks == null) return;
    final newMap = Map<String, String>.from(state.currentFillInBlanks!);
    newMap[id] = value;
    state = state.copyWith(currentFillInBlanks: newMap);
  }



  void removeLetterFromInput(int index) {
     if (state.currentWordInput == null) return;
     
     final input = List<String?>.from(state.currentWordInput!);
     final letter = input[index];
     
     if (letter != null) {
        input[index] = null;
        
        // Return to jumbled list
        // Find the first empty string in jumbled list that is currently "used"
        // Since we don't track original index, we just need to put it back into ANY empty slot?
        // No, the user expects the button to reappear in its original position usually.
        // But here we replaced the original position with "".
        // So we need to find which "box" in jumbledLetters was cleared.
        // But we don't know WHICH one if there are duplicate letters (e.g. two A's).
        // Simple heuristic: Find the first empty string in jumbledLetters.
        // Better Heuristic: Ideally we should track usage indices. 
        // For MVP: Iterate jumbledLetters, find first "" and restore... 
        // BUT wait! If I have 'A' at index 0 and 'A' at index 5. I use index 5.
        // If I put it back at index 0, the order changes.
        // The simplistic approach: Just put it back in the first available empty slot in jumbled list.
        // This makes the "hole" fill up.
        
        // Actually, if we just want to re-enable the button, we can hunt for the first "" 
        // in jumbledLetters and set it back? 
        // NO. Because `jumbledLetters` is the source of truth for the UI buttons.
        // If index 2 is "", button 2 is hidden.
        
        // Let's iterate jumbledLetters. WE DON'T KNOW where it came from.
        // To fix this properly, `currentWordInput` should probably store source indices, like `int?`.
        // BUT to keep it simple: We will NOT remove from `jumbledLetters`, we will just append to Input.
        // And `jumbledLetters` stays as is? No, then user can use same letter twice.
        
        // Revised Simple Logic:
        // We hunt for the first occurrence of "" in jumbledLetters.
        // But wait, we need to know what the letter was. We have `letter`.
        // We don't know if that particular "" was `letter` originally.
        
        // OK, serious logic: `jumbledLetters` should NOT change. 
        // We should have `List<bool> jumbledLetterUsed`.
        // Refactoring state is too much work now.
        
        // Workaround: We will restore the letter to the FIRST empty slot in jumbledLetters.
        // This might shuffle things if the user does things out of order, but it's acceptable for now.
        // ACTUALLY, we can't do that because `jumbledLetters` holds the VALUES.
        // If index 0 is "A" and index 1 is "B".
        // If I set index 0 to "", I know index 0 WAS "A".
        // Wait, if I set it to "", I LOST the value "A".
        
        // AH! I shouldn't replace with "". I should have a separate `used` list.
        // OR: I modify `jumbledLetters` to be a list of objects?
        
        // Alternative: `jumbledLetters` is immutable.
        // `currentWordInput` stores the VALUE.
        // How do we know which jumbled letter is used?
        // We can count frequencies.
        // If `jumbledLetters` has two "A"s, and `currentWordInput` has one "A", we show one "A" as available.
        // Which one? The first available one.
        
        // Let's implement this:
        // `jumbledLetters` remains STATIC (don't mutate it).
        // Wait, in `selectJumbledLetter` I mutated it.
        // I need to NOT loose the data.
        
        // Let's use a "masked" approach.
        // `jumbledLetters` in practice_controller is actually the DISPLAY list.
        // I need the "original" list?
        // The `state.jumbledLetters` gets mutated in my previous code thought.
        
        // FIX: I will change `removeLetterFromInput` to restore the letter.
        // BUT I don't know where to restore it to if I erased it with "".
        
        // Hack: `selectJumbledLetter` will replace the letter with a placeholder string that encodes the letter but marks it hidden?
        // E.g. "#A". Then UI renders it as invisible.
        // And when removing, we find "#A" and turn it back to "A".
        
         final jumbled = List<String>.from(state.jumbledLetters!);
         // Find first occurrence of "#$letter"
         final hiddenMark = "#$letter";
         final slotIndex = jumbled.indexOf(hiddenMark);
         if (slotIndex != -1) {
            jumbled[slotIndex] = letter;
         }
         
         state = state.copyWith(currentWordInput: input, jumbledLetters: jumbled);
     }
  }

  void selectJumbledLetter(int index) {
      if (state.currentWordInput == null || state.jumbledLetters == null) return;
      
      final letter = state.jumbledLetters![index];
      if (letter.startsWith("#")) return; // Already used

      // Find first empty slot
      final input = List<String?>.from(state.currentWordInput!);
      final emptyIndex = input.indexOf(null);
      
      if (emptyIndex != -1) {
         input[emptyIndex] = letter;
         
         // Mark used in jumbled list by prefixing #
         final jumbled = List<String>.from(state.jumbledLetters!);
         jumbled[index] = "#$letter"; 
         
         state = state.copyWith(currentWordInput: input, jumbledLetters: jumbled);
      }
  }

  void submitAnswer() {
    if (state.currentQuestion == null) return;
    
    bool correct = false;
    final q = state.currentQuestion!;
    
    if (q.type == QuestionType.textInput) {
      if (state.userAnswer?.trim() == q.correctAnswerText) {
        correct = true;
      }
    } else if (q.type == QuestionType.mcq) {
      if (state.selectedOption == q.correctAnswerIndex) {
        correct = true;
      }
    } else if (q.type == QuestionType.sorting) {
      if (listEquals(state.currentSortedItems, q.options)) {
        correct = true;
      }
    } else if (q.type == QuestionType.dragAndDrop) {
      bool allCorrect = true;
      if (state.currentDragAssignments == null || state.currentDragAssignments!.length != q.dragItems.length) {
         allCorrect = false;
      } else {
         for (final item in q.dragItems) {
            final assignedGroup = state.currentDragAssignments![item.id];
            if (assignedGroup != item.targetGroupId) {
               allCorrect = false;
               break;
            }
         }
      }
      correct = allCorrect;
    } else if (q.type == QuestionType.fillInTheBlank) {
      bool allCorrect = true;
      try {
        final Map<String, dynamic> correctAnswers = jsonDecode(q.correctAnswerText ?? '{}');
        if (correctAnswers.isEmpty) {
           allCorrect = false; 
        } else {
           correctAnswers.forEach((key, value) {
              final userVal = state.currentFillInBlanks?[key]?.trim();
              if (userVal != value.toString()) {
                allCorrect = false;
              }
           });
        }
      } catch (e) {
        debugPrint("Error parsing fillInTheBlank answers: $e");
        allCorrect = false;
      }
      correct = allCorrect;
    } else if (q.type == QuestionType.fourPicsOneWord) {
       final check = state.currentWordInput?.join("").toUpperCase();
       if (check == q.correctAnswerText?.toUpperCase()) {
         correct = true;
       }
    } else if (q.type == QuestionType.imageChoice) {
      if (state.selectedOption == q.correctAnswerIndex) {
         correct = true;
      }
    }

    // --- SMART SCORE ALGORITHM ---
    final int currentScore = state.smartScore;
    final int currentStreak = correct ? state.streak + 1 : 0; // Reset on error
    final Difficulty qDiff = q.difficulty;
    
    int scoreChange = 0;
    
    if (correct) {
       // GAIN LOGIC
       int baseGain = 10;
       
       // Stages
       if (currentScore >= 90) baseGain = 2;       // Mastery (Challenge Zone)
       else if (currentScore >= 70) baseGain = 4;  // Proficiency
       else if (currentScore >= 40) baseGain = 6;  // Practice
       else baseGain = 10;                         // Exploration (Fast growth)
       
       // Streak Bonus (Small incentive)
       int streakBonus = (currentStreak >= 2) ? 1 : 0;
       if (currentStreak >= 5) streakBonus = 2;
       if (currentStreak >= 10) streakBonus = 3;
       
       // Difficulty Bonus
       if (qDiff == Difficulty.hard && currentScore < 50) {
          baseGain += 5;
       }
       
       scoreChange = baseGain + streakBonus;
       
    } else {
       // PENALTY LOGIC
       int basePenalty = 2;
       
       // Stages (Higher score = Higher risk)
       if (currentScore >= 90) basePenalty = 8;     // Mastery (One slip hurts)
       else if (currentScore >= 70) basePenalty = 6;
       else if (currentScore >= 40) basePenalty = 4;
       else basePenalty = 2;                        // Forgiving early
       
       // Streak Protection
       if (state.streak >= 5) {
          basePenalty = (basePenalty ~/ 2);
       }
       
       scoreChange = -basePenalty;
    }
    
    int newScore = currentScore + scoreChange;
    
    // Bounds Check
    if (newScore > 100) newScore = 100;
    if (newScore < 0) newScore = 0;

    state = state.copyWith(
      isChecked: true,
      isCorrect: correct,
      smartScore: newScore,
      questionsAnswered: state.questionsAnswered + 1,
      correctAnswers: state.correctAnswers + (correct ? 1 : 0),
      streak: currentStreak,
    );
  }

  void continueToNext(void Function() onNoQuestions) {
    // Attempt to load next
    _loadNextQuestion();
    
    // If after attempting to load, we still have no question (shouldn't happen with fallback, but safe check)
    if (state.currentQuestion == null) {
      onNoQuestions();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Updated Provider family to accept skillId
final practiceProvider = StateNotifierProvider.family.autoDispose<PracticeController, PracticeState, String>((ref, skillId) {
  return PracticeController(skillId);
});
