import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/colors.dart';
import '../../domain/models.dart';
import '../practice_controller.dart';
import 'numeric_keyboard.dart';
import 'measure_view.dart';

class QuestionView extends ConsumerWidget {
  final String skillId;
  const QuestionView({super.key, required this.skillId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(practiceProvider(skillId));
    final question = state.currentQuestion;

    if (question == null) return const Center(child: CircularProgressIndicator());

    // Check if we should merge the last text part with the input inline
    final bool shouldMergeInput = question.type == QuestionType.textInput && 
                                  question.parts.isNotEmpty && 
                                  (question.parts.last.type == QuestionPartType.text || question.parts.last.type == QuestionPartType.math);


    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        key: ValueKey(question.id),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuestionAudioControl(question: question),
              const Gap(8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...question.parts
                        .where((p) => !(question.type == QuestionType.fourPicsOneWord && p.type == QuestionPartType.image))
                        .where((p) => !shouldMergeInput || p != question.parts.last) // Skip last part if merging
                        .map((part) => _buildPart(ref, part)),
                    
                    // Render merged input if applicable
                    if (shouldMergeInput)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.start,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildInlinePart(ref, question.parts.last),
                            _buildTextInput(ref, state.userAnswer, isInline: true),
                          ],
                        ),
                      ),
                      
                    // Render simple text input below content (for standard math/text questions)
                    if (question.type == QuestionType.textInput && !shouldMergeInput)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                        child: _buildTextInput(ref, state.userAnswer),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(32),
          // Input Area (MCQ, DragDrop, etc.)
          if (question.type == QuestionType.mcq)
            // Use Rich Options renderer if rich options exist OR if we desire grid layout
            question.richOptions.isNotEmpty 
              ? _buildImageOptions(ref, question.richOptions, state.selectedOption, state.selectedOptions, question.isMultiSelect, question.isVertical, question.showSubmitButton)
              : _buildOptions(ref, question.options, state.selectedOption, state.selectedOptions, question.isMultiSelect, question.isVertical, question.showSubmitButton)
          else if (question.type == QuestionType.sorting)
            _buildSortingView(ref, state.currentSortedItems ?? [])
          else if (question.type == QuestionType.dragAndDrop)
            _buildDragDropView(ref, question.groups, question.dragItems, state.currentDragAssignments ?? {})
          else if (question.type == QuestionType.fillInTheBlank)
            const SizedBox() // Inputs are inline in Question Content
          else if (question.type == QuestionType.fourPicsOneWord)
            _buildFourPicsOneWordView(ref, question.parts, state.currentWordInput ?? [], state.jumbledLetters ?? [])
          else if (question.type == QuestionType.imageChoice)
            _buildImageOptions(ref, question.richOptions.isNotEmpty ? question.richOptions : question.options.map((e) => RichOption.fromDynamic(e)).toList(), state.selectedOption, state.selectedOptions, question.isMultiSelect, question.isVertical, question.showSubmitButton)
          else if (question.type == QuestionType.measure)
            MeasureView(skillId: skillId),

          const Gap(40),
          
          // --- ADAPTIVE: Hint Button ---
          if (state.hintText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                     showDialog(
                       context: context, 
                       builder: (c) => AlertDialog(
                         title: Row(
                           children: const [
                             Icon(Icons.lightbulb, color: Colors.amber),
                             Gap(8),
                             Text("Hint"),
                           ],
                         ),
                         content: Column(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Text(state.hintText!, style: const TextStyle(fontSize: 16)),
                             if (state.hintImage != null)
                               Padding(
                                 padding: const EdgeInsets.only(top: 12.0),
                                 child: Image.network(
                                   state.hintImage!,
                                   height: 150,
                                   errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
                                 ),
                               ),
                           ],
                         ),
                         actions: [
                           TextButton(onPressed: () => Navigator.pop(c), child: const Text("Got it"))
                         ],
                       )
                     );
                  }, 
                  icon: const Icon(Icons.lightbulb_outline, color: Colors.amber), 
                  label: const Text("Need a hint?", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.amber.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ),

          // Submit Button Logic
          // Show if:
          // 1. Explicitly requested (showSubmitButton == true)
          // 2. Multi-select (user needs to confirm selection)
          // 3. Not a simple choice question (e.g. text input, drag drop, sorting always need submit)
          if (state.activeInputId == null && 
              (question.showSubmitButton || 
               question.isMultiSelect || 
               (question.type != QuestionType.mcq && question.type != QuestionType.imageChoice)))
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(practiceProvider(skillId).notifier).submitAnswer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  elevation: 0,
                ),
                child: const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          
          if (state.activeInputId != null)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: NumericKeyboard(
                onDigit: (digit) => ref.read(practiceProvider(skillId).notifier).appendDigit(digit),
                onBackspace: () => ref.read(practiceProvider(skillId).notifier).backspace(),
                onSubmit: () => ref.read(practiceProvider(skillId).notifier).submitAnswer(),
              ),
            ),
        ],
      ).animate().fadeIn(duration: 400.ms).animate(target: state.shouldShake ? 1 : 0).shake(hz: 8, duration: 400.ms, curve: Curves.easeInOutCubic),
    );
  }
  Widget _buildSafeImage(String url, {double? height, double? width, BoxFit fit = BoxFit.contain}) {
    if (url.isEmpty) return const SizedBox();

    if (url.trim().startsWith('<svg')) {
      return SvgPicture.string(
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

  Widget _buildPart(WidgetRef ref, QuestionPart part) {
    switch (part.type) {
      case QuestionPartType.text:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: MarkdownBody(
            data: part.content ?? '',
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              strong: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary), // Ultra bold for **text**
            ),
          ),
        );
      case QuestionPartType.image:
        if (part.imageUrl == null) return const SizedBox();
        return Padding(
           padding: const EdgeInsets.only(bottom: 12.0),
           child: _buildSafeImage(part.imageUrl!, height: part.height ?? 150),
        );
      case QuestionPartType.math:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Math.tex(
            (part.content ?? '').replaceAll(RegExp(r'[\r\n]'), ' '),
            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            onErrorFallback: (err) => Text(part.content ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
        );
       case QuestionPartType.svg:
         return Padding(
           padding: const EdgeInsets.only(bottom: 12.0),
           child: SvgPicture.string(
             part.content ?? '',
             height: part.height ?? 150,
             placeholderBuilder: (c) => const Icon(Icons.image, size: 80, color: Colors.grey),
           ),
         );
       case QuestionPartType.diagram:
         // Fallback if no SVG logic yet
         return const Padding(
           padding: EdgeInsets.only(bottom: 12.0),
           child: Icon(Icons.category, size: 80, color: Colors.blueAccent),
         );
       case QuestionPartType.sequence: // Wrap for inline layout
         return Padding(
           padding: const EdgeInsets.only(bottom: 12.0),
           child: Wrap(
             crossAxisAlignment: WrapCrossAlignment.center, // Align input fields with text
             alignment: WrapAlignment.start,
             spacing: 8,
             runSpacing: 8,
             children: part.children?.map((child) => _buildInlinePart(ref, child)).toList() ?? [],
           ),
         );
       case QuestionPartType.input:
         return Padding(
           padding: const EdgeInsets.only(bottom: 12.0),
           child: _buildInlinePart(ref, part),
         );
       default:
         return const SizedBox();
    }
  }

  Widget _buildInlinePart(WidgetRef ref, QuestionPart part) {
    if (part.type == QuestionPartType.text) {
       return Text(
          part.content ?? '',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
       );
    } else if (part.type == QuestionPartType.input) {
       final isActive = ref.read(practiceProvider(skillId)).activeInputId == part.id;
       final textValue = ref.read(practiceProvider(skillId)).currentFillInBlanks?[part.id] ?? "";
       
       return SizedBox(
         width: 70,
         child: TextField(
           controller: TextEditingController.fromValue(TextEditingValue(text: textValue, selection: TextSelection.collapsed(offset: textValue.length))),
           // onChanged: (val) => ref.read(practiceProvider(skillId).notifier).updateFillInBlank(part.id ?? 'unknown', val),
           onTap: () {
             // Set active
             ref.read(practiceProvider(skillId).notifier).setActiveInput(part.id);
           },
           readOnly: true,
           showCursor: true,
           textAlign: TextAlign.center,
           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
           decoration: InputDecoration(
             border: OutlineInputBorder(
                borderSide: BorderSide(color: isActive ? AppColors.primaryGreen : Colors.grey, width: isActive ? 2 : 1),
             ),
             enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: isActive ? AppColors.primaryGreen : Colors.grey, width: isActive ? 2 : 1),
             ),
             focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
             ),
             contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
             isDense: true,
             filled: true,
             fillColor: isActive ? Colors.green.shade50 : Colors.blue.shade50,
           ),
         ),
       );
    } else if (part.type == QuestionPartType.svg) {
         return SvgPicture.string(
           part.content ?? '',
           height: part.height ?? 40,
           placeholderBuilder: (c) => const Icon(Icons.image, size: 24, color: Colors.grey),
         );
    } else if (part.type == QuestionPartType.image) {
         if (part.imageUrl == null) return const SizedBox();
         return _buildSafeImage(part.imageUrl!, height: part.height ?? 50, width: 50);
    } else {
      return const SizedBox();
    }
  }
  Widget _buildTextInput(WidgetRef ref, String? currentVal, {bool isInline = false}) {
    final isActive = ref.read(practiceProvider(skillId)).activeInputId == '__main_text_input__';
    final textValue = ref.read(practiceProvider(skillId)).userAnswer ?? "";
    
    // If inline, no Center, smaller width
    final inputWidget = SizedBox(
        width: isInline ? 80 : 150,
        child: TextField(
          controller: TextEditingController(text: textValue),
          // onChanged: (val) => ref.read(practiceProvider(skillId).notifier).setTextInput(val),
          onTap: () {
             ref.read(practiceProvider(skillId).notifier).setActiveInput('__main_text_input__');
          },
          readOnly: true,
          showCursor: true,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: isInline ? 20 : 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            border: OutlineInputBorder(
               borderSide: BorderSide(color: isActive ? AppColors.primaryGreen : Colors.grey, width: isActive ? 2 : 1)
            ),
            enabledBorder: OutlineInputBorder(
               borderSide: BorderSide(color: isActive ? AppColors.primaryGreen : Colors.grey, width: isActive ? 2 : 1)
            ),
            focusedBorder: OutlineInputBorder(
               borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: isInline ? 6 : 10, vertical: isInline ? 6 : 10),
            filled: true,
            fillColor: isActive ? Colors.green.shade50 : Colors.white,
          ),
        ),
      );

    if (isInline) return inputWidget;
    
    // For block input, allow parent alignment (usually left inside the question column)
    return inputWidget;
  }

  Widget _buildOptions(WidgetRef ref, List<String> options, int? selected, List<int> selectedIndices, bool isMultiSelect, bool isVertical, bool showSubmitButton) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isVertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(options.length, (index) {
              final isSelected = isMultiSelect ? selectedIndices.contains(index) : selected == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GestureDetector(
                  onTap: () {
                     ref.read(practiceProvider(skillId).notifier).selectOption(index);
                     if (!isMultiSelect && !showSubmitButton) {
                        ref.read(practiceProvider(skillId).notifier).submitAnswer();
                     }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.lightGreen : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (isMultiSelect)
                          Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Icon(
                              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                              color: isSelected ? AppColors.darkGreen : Colors.grey,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            options[index],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.darkGreen : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: List.generate(options.length, (index) {
            final isSelected = isMultiSelect ? selectedIndices.contains(index) : selected == index;
            return GestureDetector(
              onTap: () {
                 ref.read(practiceProvider(skillId).notifier).selectOption(index);
                 if (!isMultiSelect && !showSubmitButton) {
                    ref.read(practiceProvider(skillId).notifier).submitAnswer();
                 }
              },
              child: Container(
                constraints: BoxConstraints(
                  minWidth: 80,
                  maxWidth: constraints.maxWidth,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.lightGreen : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isMultiSelect)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                          color: isSelected ? AppColors.darkGreen : Colors.grey,
                        ),
                      ),
                    Flexible(
                      child: Text(
                        options[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.darkGreen : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
  Widget _buildSortingView(WidgetRef ref, List<String> currentItems) {
    if (currentItems.isEmpty) return const SizedBox();

    return Center(
      child: SizedBox(
        height: 80,
        child: ReorderableListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          onReorder: (oldIndex, newIndex) {
            ref.read(practiceProvider(skillId).notifier).reorderItems(oldIndex, newIndex);
          },
          proxyDecorator: (child, index, animation) {
             return Material(
               elevation: 8,
               color: Colors.transparent,
               borderRadius: BorderRadius.circular(8),
               shadowColor: Colors.black26,
               child: child,
             );
          },
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          children: [
            for (int i = 0; i < currentItems.length; i++)
              ReorderableDragStartListener(
                key: ValueKey('sort_item_${currentItems[i]}'),
                index: i,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.primaryGreen, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                       BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))
                    ]
                  ),
                  alignment: Alignment.center,
                  child: _buildSortItemContent(currentItems[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortItemContent(String content) {
    if (content.trim().startsWith('<svg') || content.toLowerCase().endsWith('.svg')) {
      return _buildSafeImage(content, height: 40, fit: BoxFit.contain);
    }
    if (content.startsWith('http') || content.toLowerCase().endsWith('.png') || content.toLowerCase().endsWith('.jpg')) {
      return _buildSafeImage(content, height: 40, fit: BoxFit.contain);
    }
    return Text(
      content,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    );
  }
  Widget _buildDragDropView(
      WidgetRef ref, List<DragDropGroup> groups, List<DragDropItem> items, Map<String, String> assignments) {
    
    // Identify unassigned items
    final unassigned = items.where((i) => !assignments.containsKey(i.id)).toList();

    return Column(
      children: [
        // Buckets (Drop Targets)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: groups.map((group) {
             final groupItems = items.where((i) => assignments[i.id] == group.id).toList();
             
             return Expanded(
               child: DragTarget<String>(
                 onAcceptWithDetails: (details) {
                   ref.read(practiceProvider(skillId).notifier).assignDragItem(details.data, group.id);
                 },
                 builder: (context, candidateData, rejectedData) {
                   return Container(
                     margin: const EdgeInsets.symmetric(horizontal: 4),
                     padding: const EdgeInsets.all(8),
                     constraints: const BoxConstraints(minHeight: 200),
                     decoration: BoxDecoration(
                       border: Border.all(color: AppColors.primaryGreen, width: 2),
                       borderRadius: BorderRadius.circular(8),
                       color: candidateData.isNotEmpty ? AppColors.lightGreen.withOpacity(0.5) : Colors.white,
                     ),
                     child: Column(
                       children: [
                         Text(group.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
                         if (group.imageUrl != null)
                           _buildSafeImage(group.imageUrl!, height: 50),
                         const Divider(),
                         // Items inside bucket
                         ...groupItems.map((item) => Draggable<String>(
                           data: item.id,
                           feedback: Material(
                             color: Colors.transparent,
                             child: _buildDragItem(item, isDragging: true),
                           ),
                           childWhenDragging: Opacity(opacity: 0.5, child: _buildDragItem(item)),
                           child: _buildDragItem(item),
                         )),
                       ],
                     ),
                   );
                 },
               ),
             );
          }).toList(),
        ),
        const Gap(32),
        // Source Area (Unassigned)
        DragTarget<String>(
          onAcceptWithDetails: (details) {
             // Return to source
             ref.read(practiceProvider(skillId).notifier).assignDragItem(details.data, null);
          },
          builder: (context, candidateData, rejectedData) {
             return Container(
               width: double.infinity,
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: candidateData.isNotEmpty ? Colors.grey.shade200 : Colors.transparent,
                 border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                 borderRadius: BorderRadius.circular(8),
               ),
               child: Wrap(
                 alignment: WrapAlignment.center,
                 spacing: 16,
                 runSpacing: 16,
                 children: unassigned.map((item) => Draggable<String>(
                   data: item.id,
                   feedback: Material(
                     color: Colors.transparent,
                     child: _buildDragItem(item, isDragging: true),
                   ),
                   childWhenDragging: Opacity(opacity: 0.0, child: _buildDragItem(item)),
                   child: _buildDragItem(item),
                 )).toList(),
               ),
             );
          }
        ),
      ],
    );
  }

  Widget _buildDragItem(DragDropItem item, {bool isDragging = false}) {
    // If image
    if (item.type == 'image') {
      if (item.content.toLowerCase().endsWith('.svg')) {
          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              boxShadow: isDragging ? [const BoxShadow(blurRadius: 10, color: Colors.black26)] : [],
            ),
            child: _buildSafeImage(
              item.content,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          );
      }
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isDragging ? [const BoxShadow(blurRadius: 10, color: Colors.black26)] : [],
        ),
        child: item.content.startsWith('http') 
            ? _buildSafeImage(
                item.content,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              )
            // If it's not a URL, it might be an Emoji or short text labeled as image by mistake?
            // Or a local asset? Assuming text/emoji if short.
            : Center(child: Text(item.content, style: const TextStyle(fontSize: 32))),
      );
    }
    // If SVG
    if (item.type == 'svg') {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isDragging ? [const BoxShadow(blurRadius: 10, color: Colors.black26)] : [],
        ),
        child: item.content.startsWith('http') 
          ? _buildSafeImage(
              item.content,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            )
          : SvgPicture.string(
              item.content,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              placeholderBuilder: (c) => const Icon(Icons.image, size: 40, color: Colors.grey),
            ),
      );
    }
    // Else Text
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          border: Border.all(color: Colors.blue.shade200),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDragging ? [const BoxShadow(blurRadius: 10, color: Colors.black26)] : [],
        ),
        child: Text(
          item.content,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
    );
  }


  Widget _buildFourPicsOneWordView(WidgetRef ref, List<QuestionPart> parts, List<String?>? input, List<String>? letters) {
    // 1. Image Grid (Expect 4 images)
    final images = parts.where((p) => p.type == QuestionPartType.image).toList();
    final safeInput = input ?? [];
    final safeLetters = letters ?? [];
    
    return Column(
      children: [
        // Images Grid
        if (images.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: images.length == 1 
            ? SizedBox(
                height: 300,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildSafeImage(
                         images[0].imageUrl ?? "",
                         fit: BoxFit.contain,
                       ),
                ),
              )
            : SizedBox(
              height: 300, 
              child: GridView.builder(
                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: 2,
                   crossAxisSpacing: 8,
                   mainAxisSpacing: 8,
                 ),
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: images.length,
                 itemBuilder: (context, index) {
                   final img = images[index];
                   return ClipRRect(
                     borderRadius: BorderRadius.circular(8),
                     child: _buildSafeImage(
                       img.imageUrl ?? "",
                       fit: BoxFit.cover,
                     ),
                   );
                 },
              ),
            ),
        ),
        
        const Gap(24),
        
        // Answer Slots (Inputs)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(safeInput.length, (index) {
             final char = safeInput[index];
             final isFilled = char != null && char.isNotEmpty;
             return GestureDetector(
               onTap: () {
                 if (isFilled) {
                    ref.read(practiceProvider(skillId).notifier).removeLetterFromInput(index);
                 }
               },
               child: Container(
                 width: 50,
                 height: 50,
                 alignment: Alignment.center,
                 decoration: BoxDecoration(
                   color: isFilled ? Colors.blue.shade50 : Colors.grey.shade100,
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: isFilled ? Colors.blue : Colors.grey.shade400, width: 2),
                   boxShadow: isFilled ? [
                     BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                   ] : [],
                 ),
                 child: Text(
                   char ?? "",
                   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                 ),
               ),
             );
          }),
        ),
        
        const Gap(32),
        
        // Jumbled Letters Keyboard
        // Only show if we have letters
        if (safeLetters.isNotEmpty)
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(safeLetters.length, (index) {
             final char = safeLetters[index];
             final isHidden = char.startsWith("#") || char.isEmpty;
             
             // Extract real char if hidden logic used #A
             final displayChar = isHidden ? "" : char;
             
             return GestureDetector(
               onTap: isHidden ? null : () {
                  ref.read(practiceProvider(skillId).notifier).selectJumbledLetter(index);
               },
               child: AnimatedOpacity(
                 duration: 200.ms,
                 opacity: isHidden ? 0.0 : 1.0,
                 child: Container(
                   width: 45,
                   height: 45,
                   alignment: Alignment.center,
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(6),
                     border: Border.all(color: Colors.grey.shade300),
                     boxShadow: [
                       BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, 2))
                     ]
                   ),
                   child: Text(
                     displayChar,
                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                   ),
                 ),
               ),
             );
          }),
        ),
      ],
    );
  }

  Widget _buildImageOptions(WidgetRef ref, List<RichOption> options, int? selected, List<int> selectedIndices, bool isMultiSelect, bool isVertical, bool showSubmitButton) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2;
          if (constraints.maxWidth > 500 && options.length >= 3) {
            crossAxisCount = 3;
          }
          
          double spacing = 16.0;
          
          if (isVertical) {
             return Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: List.generate(options.length, (index) {
                  final opt = options[index];
                  final isSelected = isMultiSelect ? selectedIndices.contains(index) : selected == index;
                  final hasImage = opt.imageUrl != null && opt.imageUrl!.isNotEmpty;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: () {
                         ref.read(practiceProvider(skillId).notifier).selectOption(index);
                         // Auto submit if single select and submit button hidden
                         if (!isMultiSelect && !showSubmitButton) {
                            ref.read(practiceProvider(skillId).notifier).submitAnswer();
                         }
                      },
                      child: Container(
                         width: double.infinity,
                         decoration: BoxDecoration(
                           border: Border.all(
                              color: isSelected ? AppColors.primaryGreen : Colors.lightBlue.shade100,
                              width: isSelected ? 4 : 2, 
                           ),
                           borderRadius: BorderRadius.circular(12),
                           color: Colors.white,
                         ),
                         child: Stack(
                           children: [
                             Row(
                               children: [
                                  if (hasImage)
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxHeight: 120),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: _buildSafeImage(
                                            opt.imageUrl!,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (opt.text != null && opt.text!.isNotEmpty)
                                    Expanded(
                                      flex: hasImage ? 2 : 1, // Give more space to text if image exists
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                        alignment: Alignment.centerLeft,
                                        color: isSelected ? AppColors.lightGreen : Colors.transparent,
                                        child: Text(
                                          opt.text!,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold, 
                                            fontSize: 20, 
                                            color: isSelected ? AppColors.darkGreen : AppColors.textPrimary
                                          ),
                                        ),
                                      ),
                                    ),
                               ],
                             ),
                             if (isMultiSelect)
                               Positioned(
                                 top: 8,
                                 right: 8,
                                 child: Container(
                                   decoration: BoxDecoration(
                                     color: isSelected ? AppColors.primaryGreen : Colors.white,
                                     shape: BoxShape.circle,
                                     border: Border.all(color: AppColors.primaryGreen, width: 2),
                                   ),
                                   padding: const EdgeInsets.all(4),
                                   child: Icon(
                                     Icons.check,
                                     size: 16,
                                     color: isSelected ? Colors.white : Colors.transparent,
                                   ),
                                 ),
                               ),
                           ],
                         ),
                      ),
                    ),
                  );
               }),
             );
          }
          
          // Calculate itemWidth to fit exactly `crossAxisCount` items in the row
          double itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(options.length, (index) {
               final opt = options[index];
               final isSelected = isMultiSelect ? selectedIndices.contains(index) : selected == index;
               final hasImage = opt.imageUrl != null && opt.imageUrl!.isNotEmpty;
               
               return GestureDetector(
                 onTap: () {
                    ref.read(practiceProvider(skillId).notifier).selectOption(index);
                    if (!isMultiSelect && !showSubmitButton) {
                       ref.read(practiceProvider(skillId).notifier).submitAnswer();
                    }
                 },
                 child: Container(
                   width: itemWidth,
                   // Height is auto (no fixed height or aspect ratio)
                   decoration: BoxDecoration(
                     border: Border.all(
                        color: isSelected ? AppColors.primaryGreen : Colors.lightBlue.shade100,
                        width: isSelected ? 4 : 2, 
                     ),
                     borderRadius: BorderRadius.circular(12),
                     color: Colors.white,
                   ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min, // Hug content height
                          children: [
                            if (hasImage)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 150), // Prevent overly tall images
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildSafeImage(
                                    opt.imageUrl!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            if (opt.text != null && opt.text!.isNotEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                color: isSelected ? AppColors.lightGreen : (hasImage ? Colors.blue.shade50 : Colors.transparent),
                                alignment: Alignment.center,
                                child: Text(
                                  opt.text!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: hasImage ? 16 : 20, 
                                    color: isSelected ? AppColors.darkGreen : AppColors.textPrimary
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (isMultiSelect)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryGreen : Colors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primaryGreen, width: 2),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.check,
                                size: 16,
                                color: isSelected ? Colors.white : Colors.transparent,
                              ),
                            ),
                          ),
                      ],
                    ),
                 ),
               );
            }),
          );
        }
      ),
    );
  }


}

class QuestionAudioControl extends StatefulWidget {
  final QuestionModel question;
  const QuestionAudioControl({super.key, required this.question});

  @override
  State<QuestionAudioControl> createState() => _QuestionAudioControlState();
}

class _QuestionAudioControlState extends State<QuestionAudioControl> {
  late FlutterTts flutterTts;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    
    flutterTts.setStartHandler(() {
      if (mounted) setState(() => isSpeaking = true);
    });

    flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => isSpeaking = false);
    });

    flutterTts.setErrorHandler((msg) {
      if (mounted) setState(() => isSpeaking = false);
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak() async {
    if (isSpeaking) {
      await flutterTts.stop();
      if (mounted) setState(() => isSpeaking = false);
      return;
    }

    StringBuffer textToSpeak = StringBuffer();
    for (var part in widget.question.parts) {
      if (part.type == QuestionPartType.text && part.content != null) {
        textToSpeak.write("${part.content!} ");
      } else if (part.type == QuestionPartType.sequence && part.children != null) {
        for (var child in part.children!) {
          if (child.type == QuestionPartType.text && child.content != null) {
            textToSpeak.write("${child.content!} ");
          }
        }
      }
    }

    // Read options if available (Rich Options)
    if (widget.question.richOptions.isNotEmpty) {
      if (textToSpeak.isNotEmpty) textToSpeak.write(". "); // Pause after question
      
      for (var opt in widget.question.richOptions) {
        if (opt.text != null && opt.text!.isNotEmpty) {
          textToSpeak.write("${opt.text!}. "); // Pause between options
        }
      }
    }

    if (textToSpeak.isNotEmpty) {
      await flutterTts.speak(textToSpeak.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _speak,
      icon: Icon(
        isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up,
        color: AppColors.primaryGreen,
        size: 32,
      ),
      tooltip: isSpeaking ? 'Stop Reading' : 'Read Question',
    );
  }
}
