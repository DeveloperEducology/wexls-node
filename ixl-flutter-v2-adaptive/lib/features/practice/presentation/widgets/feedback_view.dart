import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/models.dart';
import '../practice_controller.dart';

class FeedbackView extends ConsumerStatefulWidget {
  final String skillId;
  const FeedbackView({super.key, required this.skillId});

  @override
  ConsumerState<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends ConsumerState<FeedbackView> {
  @override
  void initState() {
    super.initState();
    // Use postFrameCallback to safely read state and schedule timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(practiceProvider(widget.skillId));
      if (state.isCorrect) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            ref.read(practiceProvider(widget.skillId).notifier).continueToNext(() {
              if (mounted) Navigator.of(context).pop();
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceProvider(widget.skillId));
    final question = state.currentQuestion;

    if (state.isCorrect) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: AppColors.correctGreen, size: 48),
              Gap(16),
              Text(
                'Terrific!',
                style: TextStyle(
                  color: AppColors.correctGreen,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Incorrect View
    return Container(
      color: const Color(0xFFFFF4E5), // Light orange bg for warning
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sorry, incorrect...',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Gap(24),
            const Text(
              'The correct answer is:',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.primaryGreen, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getAnswerText(question!),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Gap(32),
            const Text(
              'Explanation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Gap(16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.volume_up, color: AppColors.primaryGreen),
                const Gap(8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: question.solutionParts.isEmpty 
                      ? [Text(question.solution, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary))]
                      : question.solutionParts.map((part) => _buildSolutionPart(part)).toList(),
                  ),
                ),
              ],
            ),
            const Gap(40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(practiceProvider(widget.skillId).notifier).continueToNext(() {
                    if (context.mounted) Navigator.of(context).pop();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Got it', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAnswerText(QuestionModel question) {
     if (question.type == QuestionType.textInput) {
       return question.correctAnswerText ?? '';
     }
     if (question.type == QuestionType.mcq) {
       if (question.correctAnswerIndex >= 0 && question.correctAnswerIndex < question.options.length) {
         return question.options[question.correctAnswerIndex];
       }
     }
     if (question.type == QuestionType.sorting) {
       // For sorting, the Correct Order IS the options list in our data model
       return question.options.join(" → ");
     }
     return 'Unknown Concept';
  }

  Widget _buildSolutionPart(QuestionPart part) {
    switch (part.type) {
      case QuestionPartType.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: MarkdownBody(
            data: part.content ?? '',
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
              strong: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary), 
            ),
          ),
        );
      case QuestionPartType.math:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Math.tex(
            part.content ?? '',
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      case QuestionPartType.image:
        if (part.imageUrl != null) {
           return Padding(
             padding: const EdgeInsets.only(bottom: 8.0),
             child: Image.network(part.imageUrl!, height: 100, errorBuilder: (c,e,s) => const SizedBox()),
           );
        }
        return const SizedBox();
      case QuestionPartType.svg:
        if (part.content != null) {
           return Padding(
             padding: const EdgeInsets.only(bottom: 8.0),
             child: SvgPicture.string(part.content!, height: 100),
           );
        }
        return const SizedBox();
      default:
        // Handle other types if necessary or fallback to text if content exists
        if (part.content != null) {
          return Text(part.content!);
        }
        return const SizedBox();
    }
  }
}

