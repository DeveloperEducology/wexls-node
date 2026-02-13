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

class PracticeScreen extends ConsumerStatefulWidget {
  final String skillId;

  const PracticeScreen({
    super.key,
    required this.skillId,
  });

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  
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
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Progress saved!")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pass skillId to the provider family
    final state = ref.watch(practiceProvider(widget.skillId));

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
        ),
        body: SafeArea(
          child: LayoutBuilder(
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
                    PracticeStatusBar(skillId: widget.skillId),
                    const Divider(height: 1),
                    Expanded(
                      child: _buildContent(context, state),
                    ),
                  ],
                );
              }
            }
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PracticeState state) {
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
                        child: QuestionView(skillId: widget.skillId),
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
