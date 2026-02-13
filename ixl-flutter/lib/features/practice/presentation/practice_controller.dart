import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/audio_service.dart';
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
  final List<int> selectedOptions; // For Multi-Select
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
  final String? correctAnswerFeedback; // Override for adaptive feedback
  final String? hintText;
  final String? hintImage;
  final String? nextReferredQuestionId; // If set, this QUESTION ID is forced next

  final int targetComplexity; // Dynamic complexity levelling (0-100)
  final int attempts; // How many times user tried current question

  final bool shouldShake; // Trigger UI shake animation
  final String? skillName;

  // Stage Mode Fields
  final int currentStage; // 1 to 4
  final int stageStreak; // Current consecutive correct in this stage
  final bool isStageComplete; // Trigger for "Well Done" overlay
  final bool isMastered; // Trigger for "Skill Mastered" overlay
  final bool isChallengeZone;

  PracticeState({
    this.currentQuestion,
    this.questionsAnswered = 0,
    this.correctAnswers = 0,

    this.smartScore = 0,
    this.targetComplexity = 10, // Start very easy
    this.elapsedTime = Duration.zero,
    this.isChecked = false,
    this.isCorrect = false,
    this.userAnswer,
    this.selectedOption,
    this.selectedOptions = const [],
    this.currentSortedItems,
    this.currentDragAssignments,
    this.currentFillInBlanks,
    this.jumbledLetters,
    this.currentWordInput,
    this.isLoading = true,
    this.streak = 0,
    this.activeInputId,
    this.correctAnswerFeedback,
    this.hintText,
    this.hintImage,
    this.nextReferredQuestionId,
    this.attempts = 0,

    this.shouldShake = false,
    this.skillName,
    this.currentStage = 1,
    this.stageStreak = 0,
    this.isStageComplete = false,
    this.isChallengeZone = false, // New Flag
    this.isMastered = false,
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
    List<int>? selectedOptions,
    List<String>? currentSortedItems,
    Map<String, String>? currentDragAssignments,
    Map<String, String>? currentFillInBlanks,
    List<String>? jumbledLetters,
    List<String?>? currentWordInput,
    bool? isLoading,
    int? streak,
    String? activeInputId,
    String? correctAnswerFeedback,
    String? hintText,
    String? hintImage,
    String? nextReferredQuestionId,
    int? targetComplexity,
    int? attempts,
    bool? shouldShake,
    String? skillName,
    int? currentStage,
    int? stageStreak,
    bool? isStageComplete,
    bool? isChallengeZone,
    bool? isMastered,
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
      selectedOptions: selectedOptions ?? this.selectedOptions,
      currentSortedItems: currentSortedItems ?? this.currentSortedItems,
      currentDragAssignments: currentDragAssignments ?? this.currentDragAssignments,
      currentFillInBlanks: currentFillInBlanks ?? this.currentFillInBlanks,
      jumbledLetters: jumbledLetters ?? this.jumbledLetters,
      currentWordInput: currentWordInput ?? this.currentWordInput,
      isLoading: isLoading ?? this.isLoading,
      streak: streak ?? this.streak,
      activeInputId: activeInputId ?? this.activeInputId,
      correctAnswerFeedback: correctAnswerFeedback ?? this.correctAnswerFeedback,
      hintText: hintText ?? this.hintText,
      hintImage: hintImage ?? this.hintImage,
      nextReferredQuestionId: nextReferredQuestionId ?? this.nextReferredQuestionId,
      targetComplexity: targetComplexity ?? this.targetComplexity,

      attempts: attempts ?? this.attempts,
      shouldShake: shouldShake ?? this.shouldShake,
      skillName: skillName ?? this.skillName,
      currentStage: currentStage ?? this.currentStage,
      stageStreak: stageStreak ?? this.stageStreak,
      isStageComplete: isStageComplete ?? this.isStageComplete,
      isChallengeZone: isChallengeZone ?? this.isChallengeZone,
      isMastered: isMastered ?? this.isMastered,
    );
  }

  // Define complexity/goals per stage here for easy access or create a helper in controller
  int get questionsNeededForCurrentStage {
    switch (currentStage) {
      case 1: return 3;
      case 2: return 4;
      case 3: return 5;
      default: return 5; // Stage 4 and beyond
    }
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

  static const int _pageSize = 50;
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
    
    // Resume Progress
    int resumedScore = 0;
    int resumedComplexity = 10;
    int resumedCount = 0;
    int resumedCorrect = 0;
    Duration resumedTime = Duration.zero;

    final lastSession = await SupabaseService().fetchLastSession(skillId);
    if (lastSession != null) {
       resumedScore = lastSession['smart_score'] ?? 0;
       resumedComplexity = lastSession['target_complexity'] ?? 10;
       resumedCount = lastSession['questions_answered'] ?? 0;
       resumedCorrect = lastSession['correct_count'] ?? 0;
       resumedTime = Duration(seconds: lastSession['elapsed_seconds'] ?? 0);
    }
    
    // Apply resumed state
    state = state.copyWith(
       smartScore: resumedScore,
       targetComplexity: resumedComplexity,
       questionsAnswered: resumedCount,
       correctAnswers: resumedCorrect,
       elapsedTime: resumedTime,
    );

    // Fetch Skill Name
    final skillDetails = await SupabaseService().fetchSkillDetails(skillId);
    if (skillDetails != null) {
       state = state.copyWith(skillName: skillDetails['title'] ?? skillDetails['name']);
    }

    await _loadNextQuestion();
    state = state.copyWith(isLoading: false);
  }

  void setSkillName(String name) {
    if (state.skillName == null || state.skillName != name) {
       state = state.copyWith(skillName: name);
    }
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

  Future<void> _loadNextQuestion() async {
    QuestionModel? nextQ;
    
    // ADAPTIVE: Fetch specific question if referred and not found locally
    if (state.nextReferredQuestionId != null) {
        // Check local list first
        try {
           final local = _questions.firstWhere((q) => q.id == state.nextReferredQuestionId);
           nextQ = local;
        } catch (e) {
           // Not found locally, fetch it
           debugPrint("Scaffold question not found locally, fetching: ${state.nextReferredQuestionId}");
           final fetched = await SupabaseService().fetchQuestionById(state.nextReferredQuestionId!);
           if (fetched != null) {
              _questions.add(fetched);
              nextQ = fetched;
           }
        }
        
        if (nextQ != null) {
           _seenIds.add(nextQ.id); // Mark seen
           // Force this question
        }
    }

    if (nextQ == null && _questions.isNotEmpty) {
       // Filter out seen questions to avoid repeats
       final available = _questions.where((q) => !_seenIds.contains(q.id)).toList();
       
       // Normal Selection Logic (only if nextQ not yet found)
       if (nextQ == null) {
           // Check if we need to fetch more (if we have fewer than 3 available and DB has more)
           if (available.length < 3 && _hasMoreQuestions && !_isFetchingMore) {
              _fetchMoreQuestions();
           }
    
           if (available.isNotEmpty) {
              // ADAPTIVE SELECTION - COMPLEXITY BASED
           // Target Complexity Based on Stage
           int stageTarget = 20; // default for Stage 1
           if (state.currentStage == 2) stageTarget = 45;
           if (state.currentStage == 3) stageTarget = 70;
           if (state.currentStage >= 4) stageTarget = 90;
           if (state.isChallengeZone) stageTarget = 100; // Max difficulty

           // Sort by distance to stageTarget
           available.sort((a, b) {
             final scoreA = (a.complexity ?? 50);
             final scoreB = (b.complexity ?? 50);
             final distA = (scoreA - stageTarget).abs();
             final distB = (scoreB - stageTarget).abs();
             return distA.compareTo(distB);
           });
           
           // Pick the best match, with slight randomness to avoid being boringly deterministic
           // Pick from top 3 closest matches
           int pickRange = min(3, available.length);
           nextQ = available[_rnd.nextInt(pickRange)];
           
           _seenIds.add(nextQ.id);
         } else {
           nextQ = null;
         }
       } else {
         nextQ = null; // No more questions
       }
    } else {
       // STRICT DB MODE: No fallback to MockData
       nextQ = null;
    }
    
    // Reset into NEW state
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
      
      // Preserve tracking
      targetComplexity: state.targetComplexity,
      streak: state.streak,
      correctAnswers: state.correctAnswers,
      currentStage: state.currentStage,
      stageStreak: state.stageStreak,
      isChallengeZone: state.isChallengeZone,
      isMastered: state.isMastered,
      
      elapsedTime: state.elapsedTime,
      isLoading: false,
      isChecked: false,
      isCorrect: false,
      userAnswer: null,
      selectedOption: null,
      selectedOptions: [],
      currentSortedItems: initialSortItems,
      currentDragAssignments: initialDragAssignments,

      currentFillInBlanks: nextQ != null && nextQ.type == QuestionType.fillInTheBlank ? {} : null,
      jumbledLetters: nextQ != null && nextQ.type == QuestionType.fourPicsOneWord 
          ? _generateJumbledLetters(nextQ.correctAnswerText) 
          : null,
      currentWordInput: nextQ != null && nextQ.type == QuestionType.fourPicsOneWord
          ? List<String?>.filled(nextQ.correctAnswerText?.length ?? 0, null)
          : null,
      correctAnswerFeedback: null,
      hintText: null,
      hintImage: null,
      nextReferredQuestionId: null, // Clear any pending referral
      activeInputId: (nextQ != null)
          ? (nextQ.type == QuestionType.textInput ? '__main_text_input__' 
              : (nextQ.type == QuestionType.fillInTheBlank 
                  ? nextQ.parts.firstWhere((p) => p.type == QuestionPartType.input, orElse: () => QuestionPart(type: QuestionPartType.text, content: '')).id
                  : null))
          : null,
      attempts: 0, // Reset attempts for new question
      shouldShake: false,
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
    // Check if multi-select
    final q = state.currentQuestion;
    if (q?.isMultiSelect == true) {
      final current = List<int>.from(state.selectedOptions);
      if (current.contains(index)) {
        current.remove(index);
      } else {
        current.add(index);
      }
      state = state.copyWith(selectedOptions: current);
    } else {
      // Single Select
      state = state.copyWith(selectedOption: index);
    }
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
    String? feedbackOverride;
    final q = state.currentQuestion!;
    

    
    if (q.type == QuestionType.textInput || q.type == QuestionType.measure) {
      if (state.userAnswer?.trim() == q.correctAnswerText) {
        correct = true;
      }
    } else if (q.type == QuestionType.mcq || q.type == QuestionType.imageChoice) {
      if (q.isMultiSelect) {
         final correctSet = Set<int>.from(q.correctAnswerIndices ?? []);
         final selectedSet = Set<int>.from(state.selectedOptions);
         if (setEquals(correctSet, selectedSet)) {
             correct = true;
         }
      } else {
         if (state.selectedOption == q.correctAnswerIndex) {
            correct = true;
         }
      }
    } else if (q.type == QuestionType.sorting) {
      // 0. Explicit Correct Order from Adaptive Config (Best Source of Truth)
      if (q.adaptiveConfig != null && q.adaptiveConfig!.containsKey('correct_order')) {
          final correctOrder = List<String>.from(q.adaptiveConfig!['correct_order']);
          if (listEquals(state.currentSortedItems, correctOrder)) {
             correct = true;
          }
      }
      // 0.5 Explicit Sort Rule (Ascending/Descending)
      else if (q.adaptiveConfig != null && q.adaptiveConfig!.containsKey('sort_rule')) {
          final rule = q.adaptiveConfig!['sort_rule'].toString().toLowerCase();
          bool allNumbers = q.options.every((o) => double.tryParse(o) != null);
          
          if (allNumbers) {
              final sortedOptions = List<String>.from(q.options)
                  ..sort((a, b) => double.parse(a).compareTo(double.parse(b)));
              
              if (rule == 'ascending' && listEquals(state.currentSortedItems, sortedOptions)) {
                  correct = true;
              } else if (rule == 'descending' && listEquals(state.currentSortedItems, sortedOptions.reversed.toList())) {
                  correct = true;
              }
          }
      }
      // 1. Strict Match (Trusting DB to have correct order in options)
      else if (listEquals(state.currentSortedItems, q.options)) {
        correct = true;
      } 
      // 2. Heuristic fallback: Check for numeric sorting instructions if strict match fails
      // This handles cases where 'options' in DB are not pre-sorted but the question implies a specific order.
      else if (state.currentSortedItems != null) {
          // Strip markdown and normalize
          final fullText = q.parts
              .map((p) => (p.content ?? '').replaceAll('*', '').replaceAll('_', ''))
              .join(' ')
              .toLowerCase();
          final userItems = state.currentSortedItems!;
          
          // Check if all options are essentially numbers
          bool allNumbers = q.options.every((o) => double.tryParse(o) != null);
          debugPrint("SORT DEBUG: FullText='$fullText'");
          debugPrint("SORT DEBUG: UserItems='$userItems'");
          debugPrint("SORT DEBUG: AllNumbers=$allNumbers");
          
          if (allNumbers) {
               final sortedOptions = List<String>.from(q.options)
                  ..sort((a, b) => double.parse(a).compareTo(double.parse(b)));
               
                // ASCENDING KEYWORDS
               if (fullText.contains('least to the greatest') || 
                   fullText.contains('least to greatest') ||
                   fullText.contains('smallest to the largest') ||
                   fullText.contains('smallest to largest') || 
                   fullText.contains('smallest group to the largest') || 
                   fullText.contains('least to the most') ||
                   fullText.contains('least to most') ||
                   fullText.contains('lowest to the highest') ||
                   fullText.contains('lowest to highest') ||
                   fullText.contains('increasing') ||
                   fullText.contains('fewest to the most') ||
                   fullText.contains('fewest to most') ||
                   fullText.contains('smallest number to biggest number') ||
                   fullText.contains('smallest number to the front') ||
                   fullText.contains('move the smallest number') ||
                   fullText.contains('ascending')) {
                   
                   if (listEquals(userItems, sortedOptions)) {
                       correct = true;
                   }
               }
               // DESCENDING KEYWORDS
               else if (fullText.contains('greatest to the least') || 
                        fullText.contains('greatest to least') || 
                        fullText.contains('largest to the smallest') ||
                        fullText.contains('largest to smallest') ||
                        fullText.contains('most to the least') || 
                        fullText.contains('most to least') ||
                        fullText.contains('highest to the lowest') ||
                        fullText.contains('highest to lowest') ||
                        fullText.contains('decreasing') ||
                        fullText.contains('biggest number to the smallest') ||
                        fullText.contains('biggest to smallest') ||
                        fullText.contains('descending')) {
                   
                   if (listEquals(userItems, sortedOptions.reversed.toList())) {
                       correct = true;
                   }
               }
          }
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
      if (q.isMultiSelect) {
         final correctSet = Set<int>.from(q.correctAnswerIndices ?? []);
         final selectedSet = Set<int>.from(state.selectedOptions);
         if (setEquals(correctSet, selectedSet)) correct = true;
      } else {
         if (state.selectedOption == q.correctAnswerIndex) {
            correct = true;
         }
      }
    }


    // --- ADAPTIVE: Check Misconceptions (Only if incorrect) ---
    if (!correct && q.adaptiveConfig != null && q.adaptiveConfig!.containsKey('misconception_map')) {
       final map = q.adaptiveConfig!['misconception_map'] as Map<String, dynamic>;
       String userHash = "";
       
       if (q.type == QuestionType.sorting && state.currentSortedItems != null) {
          userHash = state.currentSortedItems!.join(",");
       } else if (q.type == QuestionType.mcq && !q.isMultiSelect && state.selectedOption != null) {
          userHash = state.selectedOption.toString();
       }
       
       if (map.containsKey(userHash)) {
          feedbackOverride = map[userHash];
       }
    }

    // --- SECOND CHANCE LOGIC ---
    if (!correct && state.attempts == 0) {
      
      String? hintText;
      String? hintImage;
      
      // Check for Remediation / Hints
      if (q.adaptiveConfig != null && q.adaptiveConfig!.containsKey('remediation')) {
          final remediation = q.adaptiveConfig!['remediation'] as Map<String, dynamic>;
          hintText = remediation['hint_text'];
          hintImage = remediation['hint_image'];
      }

      // First mistake -> Give second chance
      state = state.copyWith(
          attempts: 1, 
          shouldShake: true,
          correctAnswerFeedback: feedbackOverride, // Show specific error feedback
          hintText: hintText,
          hintImage: hintImage
      );
      
      // Play Audio
      AudioService().playIncorrect();

      // Reset shake flag after animation time (approx 500ms)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) state = state.copyWith(shouldShake: false);
      });
      return; 
    }
    
    // --- SMART SCORE & ADAPTIVITY ---
    final int currentScore = state.smartScore;
    final int currentStreak = correct ? state.streak + 1 : 0; // Reset on error
    final Difficulty qDiff = q.difficulty;
    
    int scoreChange = 0;
    int newTargetComplexity = state.targetComplexity;
    String? nextReferredQuestionId; // Local variable to track referral
    
    if (correct) {
       // Play Audio
       AudioService().playCorrect();

       // GAIN LOGIC
       if (state.attempts > 0) {
          // If they got it right on 2nd try, small gain, no momentum
          scoreChange = 2; // Fixed small points
          newTargetComplexity = min(100, state.targetComplexity + 5);
       } else {
          // Normal Gain Logic
          int baseGain = 10;
          
          // Stages (Stricter Curve)
          if (currentScore >= 90) {
             baseGain = 1;     // Challenge Zone: Needs 10 perfect questions
          } else if (currentScore >= 80) {
             baseGain = 2;     // Excellence
          } else if (currentScore >= 70) {
             baseGain = 3;     // Proficiency
          } else if (currentScore >= 50) {
             baseGain = 5;     // Practice
          } else {
             baseGain = 8;     // Exploration
          }
          
          // Streak Bonus (No bonus in Challenge Zone)
          int streakBonus = 0;
          if (currentScore < 90) {
             if (currentStreak >= 10) streakBonus = 2;
             else if (currentStreak >= 5) streakBonus = 1;
          }
          
          // Difficulty Bonus (Legacy)
          if (qDiff == Difficulty.hard && currentScore < 50) {
             baseGain += 2;
          }
          
          scoreChange = baseGain + streakBonus;
          
          // ADAPTIVE LOGIC: HYBRID MOMENTUM
          int complexityBoost = 5; // Standard step
          if (currentStreak >= 3) complexityBoost = 15; // Momentum Jump
          
          newTargetComplexity = min(100, state.targetComplexity + complexityBoost);
       }
       
    } else {
       // PENALTY LOGIC
       int basePenalty = 2;
       
       // Stages (Higher score = Higher risk)
       if (currentScore >= 90) {
          // DOUBLE JEOPARDY: Challenge Zone
          // One mistake kicks you out of the zone back to ~85-88
          // Formula: (Score - 80) / 1.5 + 4
          // e.g. 91 -> 11 more than 80 -> drop ~11 points -> 80
          basePenalty = (currentScore - 82); 
          if (basePenalty < 4) basePenalty = 4; // Min penalty in challenge zone
       }
       else if (currentScore >= 80) basePenalty = 6;
       else if (currentScore >= 70) basePenalty = 5;
       else if (currentScore >= 40) basePenalty = 3;
       else basePenalty = 1;                        // Very Forgiving early
       
       // Streak Protection (Only valid below Challenge Zone)
       if (currentScore < 90 && state.streak >= 5) {
          basePenalty = (basePenalty ~/ 2);
       }
       
       scoreChange = -basePenalty;
       
       // ADAPTIVE LOGIC: BACKTRACK
       // If getting wrong, simplify to rebuild confidence
       // Standard drop: -10
       // If we were already low, be careful not to hit floor too hard
       newTargetComplexity = max(5, state.targetComplexity - 5);
       
       // Check for Scaffold Question
       if (q.adaptiveConfig != null && q.adaptiveConfig!.containsKey('remediation')) {
           final remediation = q.adaptiveConfig!['remediation'] as Map<String, dynamic>;
           if (remediation.containsKey('scaffold_question_id')) {
              // FORCE NEXT QUESTION to be the scaffold
              nextReferredQuestionId = remediation['scaffold_question_id'];
           }
       }
    }
    
    int newScore = currentScore + scoreChange;
    
    // Bounds Check
    if (newScore > 100) newScore = 100;
    if (newScore < 0) newScore = 0;

    // --- STAGE LOGIC ---
    int newStageStreak = state.stageStreak;
    bool newIsStageComplete = false;
    bool newIsMastered = false; // Initialize

    // Challenge Zone Mastery Check
    if (state.isChallengeZone) {
       if (newScore >= 100) {
          newIsMastered = true;
       }
    } else {
      // Normal Stage Progression
      if (correct) {
        newStageStreak++;
        // Dynamic Goal Check
        int goal = state.questionsNeededForCurrentStage;
        if (newStageStreak >= goal) { 
           newIsStageComplete = true;
        }
      } else {
         newStageStreak = 0; // Reset streak on error (Clears the visual bar)
      }
    }

    state = state.copyWith(
      isChecked: true,
      isCorrect: correct,
      smartScore: newScore,
      correctAnswerFeedback: feedbackOverride, // Persist feedback in final state too
      questionsAnswered: state.questionsAnswered + 1,
      correctAnswers: state.correctAnswers + (correct ? 1 : 0),
      streak: currentStreak,
      targetComplexity: newTargetComplexity,
      nextReferredQuestionId: nextReferredQuestionId, // Update for next fetch
      // Stage updates
      stageStreak: newStageStreak,
      isStageComplete: newIsStageComplete,
      isMastered: newIsMastered, // Pass it
    );
  }

  Future<void> continueToNext(void Function() onNoQuestions) async {
    // Check if we hit Stage Complete
    if (state.isStageComplete) {
       if (state.currentStage >= 4) {
          // Enter Challenge Zone instead of Mastery
          state = state.copyWith(
             isChallengeZone: true,
             isStageComplete: false,
             stageStreak: 0,
             currentStage: 5, // Just visual indicator > 4
          );
       } else {
         // Reset for next stage
         state = state.copyWith(
            currentStage: state.currentStage + 1,
            stageStreak: 0,
            isStageComplete: false,
         );
       }
    }

    // Attempt to load next
    await _loadNextQuestion();
    
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
