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
  late String _positiveMessage;

  final List<String> _compliments = [
    'Terrific!', 'Superb!', 'Excellent!', 'Fantastic!', 
    'Brilliant!', 'Great job!', 'Keep it up!', 'Outstanding!',
    'Wonderful!', 'Marvelous!'
  ];

  @override
  void initState() {
    super.initState();
    _positiveMessage = (_compliments..shuffle()).first;

    // Use postFrameCallback to safely read state and schedule timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(practiceProvider(widget.skillId));
      if (state.isCorrect) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            ref.read(practiceProvider(widget.skillId).notifier).continueToNext(() {
              // Only pop if we are actually showing a dialog/overlay, but here it's inline in body.
              // So continueToNext updates state.isChecked = false, which removes FeedbackView.
              // We don't need to pop anything.
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
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.correctGreen, size: 64),
              const Gap(16),
              Text(
                _positiveMessage,
                style: const TextStyle(
                  color: AppColors.correctGreen,
                  fontSize: 32,
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
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Header
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
               decoration: BoxDecoration(
                 color: const Color(0xFFFFF4E5), // Light orange/yellow background
                 border: const Border(
                    left: BorderSide(color: Color(0xFFF5A623), width: 4), // Orange accent
                 ),
               ),
               child: Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Icon(Icons.info_outline, color: Color(0xFFD0021B), size: 28),
                   const Gap(12),
                   Expanded(
                     child: Text(
                       state.correctAnswerFeedback ?? 'Sorry, incorrect...',
                       style: const TextStyle(
                         fontSize: 20,
                         fontWeight: FontWeight.bold,
                         color: Color(0xFFD0021B),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
             
             const Gap(24),
             
             // 1. The Question (Context)
             // We want to re-render the question parts similar to QuestionView but static
             const Text("Question", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
             const Gap(8),
             ...question!.parts.map((p) => _buildQuestionPart(p)).toList(),
             const Gap(8),
             if (question.type == QuestionType.mcq && question.isVertical)
               // Show options if vertical to give context? 
               // Actually IXL just shows the question stem, then jump to answers.
               // Let's keep it clean.
               const SizedBox(),

             const Divider(height: 48),

             // 2. You Answered
             const Text("You answered:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
             const Gap(8),
             Container(
               padding: const EdgeInsets.all(12),
               width: double.infinity,
               decoration: BoxDecoration(
                 color: const Color(0xFFFFF5F5), // Light red
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: Colors.red.shade200),
               ),
               child: _buildUserAnswerContent(question, state),
             ),

             const Gap(24),

             // 3. Correct Answer
             const Text("Correct answer:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
             const Gap(8),
             Container(
               padding: const EdgeInsets.all(12),
               width: double.infinity,
               decoration: BoxDecoration(
                 color: const Color(0xFFF0F9FF), // Light blue/green
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: AppColors.primaryGreen.withOpacity(0.5)),
               ),
               child: _buildCorrectAnswerContent(question),
             ),
             
             const Divider(height: 48),

             // 4. Explanation
             const Row(
               children: [
                 Icon(Icons.lightbulb_outline, color: AppColors.primaryGreen),
                 Gap(8),
                 Text("Explanation", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
               ],
             ),
             const Gap(16),
             
             if (question.solutionParts.isEmpty)
                MarkdownBody(
                   data: question.solution.isEmpty ? "No explanation provided." : question.solution, 
                   styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 16, color: AppColors.textPrimary, height: 1.5),
                   ),
                )
             else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: question.solutionParts.map((part) => _buildSolutionPart(part)).toList(),
                ),

             const Gap(40),
             
             SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(practiceProvider(widget.skillId).notifier).continueToNext(() {
                    if (context.mounted) Navigator.of(context).pop(); // Actually pop works if pushed, but typically we just reset state
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Got it', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
             const Gap(20),
          ],
        ),
      ),
    );
  }

  // --- Render Helpers ---

  Widget _buildSafeImage(String url, {double? height, double? width, BoxFit fit = BoxFit.contain}) {
    if (url.isEmpty) return const SizedBox();

    if (url.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        url,
        height: height,
        width: width,
        fit: fit,
        placeholderBuilder: (context) => Container(
          height: height,
          width: width,
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }
    
    return Image.network(
      url,
      height: height,
      width: width,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
         return Container(
          height: height,
          width: width,
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: SizedBox(
             width: 24, height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: width,
          color: Colors.grey.shade100,
          alignment: Alignment.center,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.grey, size: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserAnswerContent(QuestionModel question, PracticeState state) {
      if (question.type == QuestionType.mcq || question.type == QuestionType.imageChoice) {
          if (question.isMultiSelect) {
             if (state.selectedOptions.isEmpty) {
               return const Text("No options selected.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey));
             }
             return Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: state.selectedOptions.map((idx) {
                  if (idx >= 0 && idx < question.options.length) {
                     return Padding(
                       padding: const EdgeInsets.only(bottom: 4.0),
                       child: _buildOptionTextOrImage(question, idx),
                     );
                  }
                  return const SizedBox();
               }).toList(),
             );
          } else {
             if (state.selectedOption != null && state.selectedOption! >= 0 && state.selectedOption! < question.options.length) {
                 return _buildOptionTextOrImage(question, state.selectedOption!);
             } else {
                 return const Text("No option selected.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey));
             }
          }
      } else if (question.type == QuestionType.textInput) {
          return Text(
            state.userAnswer != null && state.userAnswer!.isNotEmpty ? state.userAnswer! : "(No answer)",
            style: const TextStyle(fontSize: 18, color: Color(0xFFD0021B), fontWeight: FontWeight.bold),
          );
      }
      return const Text("Incorrect response", style: TextStyle(color: Color(0xFFD0021B)));
  }

  Widget _buildCorrectAnswerContent(QuestionModel question) {
      if (question.type == QuestionType.mcq || question.type == QuestionType.imageChoice) {
          if (question.isMultiSelect) {
             final indices = question.correctAnswerIndices ?? [];
             if (indices.isEmpty) return const Text("Unknown");
             return Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: indices.map((idx) {
                  if (idx >= 0 && idx < question.options.length) {
                     return Padding(
                       padding: const EdgeInsets.only(bottom: 4.0),
                       child: _buildOptionTextOrImage(question, idx, isCorrect: true),
                     );
                  }
                  return const SizedBox();
               }).toList(),
             );
          } else {
             if (question.correctAnswerIndex >= 0 && question.correctAnswerIndex < question.options.length) {
                 return _buildOptionTextOrImage(question, question.correctAnswerIndex, isCorrect: true);
             }
             return const Text("Unknown");
          }
      } else if (question.type == QuestionType.textInput) {
          return Text(
            question.correctAnswerText ?? "Unknown",
            style: const TextStyle(fontSize: 18, color: AppColors.darkGreen, fontWeight: FontWeight.bold),
          );
      }
      return const Text("See explanation");
  }

  Widget _buildOptionTextOrImage(QuestionModel question, int index, {bool isCorrect = false}) {
      // Check if rich options
      if (question.richOptions.isNotEmpty && index < question.richOptions.length) {
         final opt = question.richOptions[index];
         final hasImage = opt.imageUrl != null;
         final hasText = opt.text != null;
         
         return Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             if (hasImage) 
               Padding(
                 padding: const EdgeInsets.only(right: 8.0),
                 child: _buildSafeImage(opt.imageUrl!, height: 40, width: 40),
               ),
             if (hasText)
               Flexible(
                 child: Text(
                   opt.text!, 
                   style: TextStyle(
                     fontSize: 18, 
                     fontWeight: FontWeight.bold, 
                     color: isCorrect ? AppColors.darkGreen : const Color(0xFFD0021B),
                   ),
                 ),
               ),
           ],
         );
      }
      
      // Fallback simple text
      return Text(
        question.options[index],
        style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold, 
          color: isCorrect ? AppColors.darkGreen : const Color(0xFFD0021B),
        ),
      );
  }

  // Reuse logic roughly from QuestionView but simplified
  Widget _buildQuestionPart(QuestionPart part) {
     switch (part.type) {
       case QuestionPartType.text:
         return MarkdownBody(data: part.content ?? '', styleSheet: MarkdownStyleSheet(p: const TextStyle(fontSize: 18, color: Colors.black87)));
       case QuestionPartType.image:
         if (part.imageUrl == null) return const SizedBox();
         return Padding(
           padding: const EdgeInsets.symmetric(vertical: 8.0),
           child: ConstrainedBox(
             constraints: const BoxConstraints(maxHeight: 200),
             child: _buildSafeImage(part.imageUrl!),
           ),
         );
       case QuestionPartType.svg:
         return SvgPicture.string(part.content ?? '', height: 150);
       case QuestionPartType.math:
         return Math.tex(part.content ?? '', textStyle: const TextStyle(fontSize: 20));
       case QuestionPartType.input:
         // Render a visual placeholder for the blank
         return Container(
           margin: const EdgeInsets.symmetric(horizontal: 4),
           width: 60,
           height: 30,
           decoration: BoxDecoration(
             border: Border(bottom: BorderSide(color: Colors.grey.shade400, width: 2)),
           ),
         );
       default:
         return const SizedBox();
     }
  }

  Widget _buildSolutionPart(QuestionPart part) {
    switch (part.type) {
      case QuestionPartType.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: MarkdownBody(
            data: part.content ?? '',
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 16, color: AppColors.textPrimary, height: 1.5),
              strong: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary), 
            ),
          ),
        );
      case QuestionPartType.math:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Math.tex(
            (part.content ?? '').replaceAll(RegExp(r'[\r\n]'), ' '),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      case QuestionPartType.image:
        if (part.imageUrl != null) {
           return Padding(
             padding: const EdgeInsets.only(bottom: 8.0),
             child: _buildSafeImage(part.imageUrl!, height: 120),
           );
        }
        return const SizedBox();
      case QuestionPartType.svg:
        if (part.content != null) {
           return Padding(
             padding: const EdgeInsets.only(bottom: 8.0),
             child: SvgPicture.string(part.content!, height: 120),
           );
        }
        return const SizedBox();
      default:
        return const SizedBox();
    }
  }
}

