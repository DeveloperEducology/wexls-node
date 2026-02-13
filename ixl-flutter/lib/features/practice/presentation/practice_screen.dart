import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../auth/presentation/login_screen.dart';
import 'practice_controller.dart';
import 'widgets/status_bar.dart';
import 'widgets/question_view.dart';
import 'widgets/feedback_view.dart';
import 'widgets/sidebar.dart';
import 'package:confetti/confetti.dart';
import '../../../core/services/audio_service.dart';
import 'widgets/stage_status_bar.dart';
import 'widgets/stage_complete_overlay.dart';
import 'widgets/skill_mastered_overlay.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final String skillId;
  final String? skillName;

  const PracticeScreen({
    super.key,
    required this.skillId,
    this.skillName,
  });

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    if (widget.skillName != null) {
       // Use post-frame to ensure provider is ready if needed, though read usually works fine.
       // But init runs before builds, and provider might auto-init.
       WidgetsBinding.instance.addPostFrameCallback((_) {
         ref.read(practiceProvider(widget.skillId).notifier).setSkillName(widget.skillName!);
       });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
  
  Future<void> _handleExit() async {
    final state = ref.read(practiceProvider(widget.skillId));
    // If no progress really made, just exit? (e.g. 0 questions).
    if (state.questionsAnswered == 0) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final currentUser = SupabaseService().currentUser;

    if (currentUser == null) {
      // Not Logged In
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text("Save Progress?"),
          content: const Text("You are not signed in. Sign in to save your results."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(false), // Don't Save
              child: const Text("Don't Save", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(c).pop(true), // Sign In & Save
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              child: const Text("Sign In & Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (shouldSave == true) {
        // Go to Login
        if (!mounted) return;
        final loggedIn = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoginScreen())
        );

        if (loggedIn == true) {
          // Now save
          await _saveData(state);
          if (mounted) Navigator.of(context).pop();
        } else {
           // User cancelled login
           // Maybe asked again? Or just stay on screen.
        }
      } else {
        // Exit without saving
        if (mounted) Navigator.of(context).pop();
      }

    } else {
      // Logged In - Ask to save
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text("Save Session?"),
          content: const Text("Do you want to save your progress data for this session?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(false), 
              child: const Text("No", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(c).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              child: const Text("Yes, Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (shouldSave == true) {
        await _saveData(state);
      }
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _saveData(PracticeState state) async {
    // Show saving indicator?
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saving progress...")));
    try {
      await SupabaseService().savePracticeSession(
        skillId: widget.skillId,
        score: state.smartScore,
        questionsAnswered: state.questionsAnswered,
        correctCount: state.correctAnswers,
        elapsedSeconds: state.elapsedTime.inSeconds,
        targetComplexity: state.targetComplexity,
        skillName: widget.skillName ?? state.skillName,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Progress saved!")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save: $e")));
    }
  }

  Future<void> _showReportDialog(BuildContext context, String qId) async {
    final controller = TextEditingController();
    final shouldSubmit = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Report Question"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What is wrong with this question? (e.g. wrong answer, typo, confusing)", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter your feedback...",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(null),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(c).pop(controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldSubmit != null && shouldSubmit.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sending report...")));
      try {
        await SupabaseService().reportQuestion(qId, shouldSubmit);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thanks for your feedback!")));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to send: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pass skillId to the provider family
    final state = ref.watch(practiceProvider(widget.skillId));

    // Listen for Milestones
    ref.listen(practiceProvider(widget.skillId), (prev, next) {
       if (prev == null) return;
       // Check thresholds
       final oldScore = prev.smartScore;
       final newScore = next.smartScore;
       
       if ((oldScore < 80 && newScore >= 80) ||
           (oldScore < 90 && newScore >= 90) ||
           (oldScore < 100 && newScore >= 100)) {
           _confettiController.play();
           AudioService().playCelebration();
       }
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleExit();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Practice', style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primaryGreen,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleExit, // Custom back handling
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'report') {
                  final qId = ref.read(practiceProvider(widget.skillId)).currentQuestion?.id;
                  if (qId != null) {
                    _showReportDialog(context, qId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No active question to report.")));
                  }
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'report',
                    child: Row(
                      children: [
                         Icon(Icons.flag, color: Colors.grey),
                         SizedBox(width: 8),
                         Text('Report Question'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
        body: SafeArea(

          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 800; // Breakpoint for desktop/tablet landscape
      
                  if (isDesktop) {
                     // Desktop Row Layout
                     return Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Expanded(
                           child: _buildContent(context, state),
                         ),
                         // Sidebar
                         PracticeSidebar(skillId: widget.skillId),
                       ],
                     );
                  } else {
                    // Mobile Column Layout
                    return Column(
                      children: [
                        StageStatusBar(
                          currentStage: state.currentStage,
                          totalStages: 4, 
                          stageStreak: state.stageStreak,
                          goal: state.questionsNeededForCurrentStage,
                          isChallengeZone: state.isChallengeZone, // Pass this
                          smartScore: state.smartScore,
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: _buildContent(context, state),
                        ),
                      ],
                    );
                  }
                }
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false, 
                  colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
                  gravity: 0.2, // Float down slowly
                  numberOfParticles: 20,
                  emissionFrequency: 0.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PracticeState state) {
    if (state.isMastered) { // Check mastery first
       return SkillMasteredOverlay(
         onFinish: () {
            Navigator.of(context).pop(); // Exit practice
         },
       );
    }
    
    if (state.isStageComplete) {
      return StageCompleteOverlay(
        nextStage: state.currentStage + 1,
        onContinue: () {
           ref.read(practiceProvider(widget.skillId).notifier).continueToNext(() {});
        },
      );
    }

    return state.isLoading
        ? const Center(child: CircularProgressIndicator())
        : state.isChecked
            ? FeedbackView(skillId: widget.skillId)
            : state.currentQuestion == null
                ? _buildNoQuestions(context)
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Added padding for better look
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // DEBUG: Show Complexity Info
                            if (state.currentQuestion != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  "Target Complexity: ${state.targetComplexity} | Q. Complexity: ${state.currentQuestion!.complexity ?? 'N/A'}",
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                                ),
                              ),
                            QuestionView(skillId: widget.skillId),
                          ],
                        ),
                      ),
                    ),
                  );
  }

  Widget _buildNoQuestions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("No questions found.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleExit, // Use exit flow
            child: const Text("Go Back"),
          )
        ],
      ),
    );
  }
}
