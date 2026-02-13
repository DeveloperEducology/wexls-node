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

class QuestionView extends ConsumerWidget {
  final String skillId;
  const QuestionView({super.key, required this.skillId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(practiceProvider(skillId));
    final question = state.currentQuestion;

    if (question == null) return const Center(child: CircularProgressIndicator());

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
                        .map((part) => _buildPart(ref, part)),
                  ],
                ),
              ),
            ],
          ),
          const Gap(32),
          // Input Area
          if (question.type == QuestionType.textInput)
            _buildTextInput(ref, state.userAnswer)
          else if (question.type == QuestionType.mcq)
            _buildOptions(ref, question.options, state.selectedOption)
          else if (question.type == QuestionType.sorting)
            _buildSortingView(ref, state.currentSortedItems ?? [])
          else if (question.type == QuestionType.dragAndDrop)
            _buildDragDropView(ref, question.groups, question.dragItems, state.currentDragAssignments ?? {})
          else if (question.type == QuestionType.fillInTheBlank)
            const SizedBox() // Inputs are inline in Question Content
          else if (question.type == QuestionType.fourPicsOneWord)
            _buildFourPicsOneWordView(ref, question.parts, state.currentWordInput ?? [], state.jumbledLetters ?? [])
          else if (question.type == QuestionType.imageChoice)
            _buildImageOptions(ref, question.richOptions.isNotEmpty ? question.richOptions : question.options.map((e) => RichOption.fromDynamic(e)).toList(), state.selectedOption),

          const Gap(40),
          if (state.activeInputId == null)
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
      ).animate().fadeIn(duration: 400.ms),
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
        if (part.imageUrl!.toLowerCase().endsWith('.svg')) {
          return Padding(
             padding: const EdgeInsets.only(bottom: 12.0),
             child: SvgPicture.network(
               part.imageUrl!,
               height: part.height ?? 150,
               placeholderBuilder: (c) => const Icon(Icons.image, size: 50, color: Colors.grey),
             ),
          );
        }
        return Padding(
           padding: const EdgeInsets.only(bottom: 12.0),
           child: Image.network(
             part.imageUrl!,
             height: part.height ?? 150,
             errorBuilder: (c,e,s) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
           ),
        );
      case QuestionPartType.math:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Math.tex(
            part.content ?? '',
            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
             alignment: WrapAlignment.center,
             spacing: 8,
             runSpacing: 8,
             children: part.children?.map((child) => _buildInlinePart(ref, child)).toList() ?? [],
           ),
         );
       case QuestionPartType.input:
         return Padding(
           padding: const EdgeInsets.only(bottom: 12.0),
           child: Center(child: _buildInlinePart(ref, part)),
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
         width: 100,
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
           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
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
             contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
         if (part.imageUrl!.toLowerCase().endsWith('.svg')) {
            return SvgPicture.network(
              part.imageUrl!,
              height: part.height ?? 50,
              placeholderBuilder: (c) => const Icon(Icons.image, size: 40, color: Colors.grey),
            );
         }
         return Image.network(
           part.imageUrl!,
           height: part.height ?? 50,
           errorBuilder: (c,e,s) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
         );
    } else {
      return const SizedBox();
    }
  }

  Widget _buildTextInput(WidgetRef ref, String? currentVal) {
    final isActive = ref.read(practiceProvider(skillId)).activeInputId == '__main_text_input__';
    final textValue = ref.read(practiceProvider(skillId)).userAnswer ?? "";
    
    return Center(
      child: SizedBox(
        width: 150,
        child: TextField(
          controller: TextEditingController(text: textValue),
          // onChanged: (val) => ref.read(practiceProvider(skillId).notifier).setTextInput(val),
          onTap: () {
             ref.read(practiceProvider(skillId).notifier).setActiveInput('__main_text_input__');
          },
          readOnly: true,
          showCursor: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            filled: true,
            fillColor: isActive ? Colors.green.shade50 : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildOptions(WidgetRef ref, List<String> options, int? selected) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: List.generate(options.length, (index) {
            final isSelected = selected == index;
            return GestureDetector(
              onTap: () => ref.read(practiceProvider(skillId).notifier).selectOption(index),
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
            );
          }),
        );
      },
    );
  }
  Widget _buildSortingView(WidgetRef ref, List<String> currentItems) {
    if (currentItems.isEmpty) return const SizedBox();

    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        ref.read(practiceProvider(skillId).notifier).reorderItems(oldIndex, newIndex);
      },
      children: [
        for (int i = 0; i < currentItems.length; i++)
          Container(
            key: ValueKey('sort_item_${currentItems[i]}'), 
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                 BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
              ]
            ),
            child: ListTile(
               leading: const Icon(Icons.drag_indicator, color: Colors.grey),
               title: Text(
                 currentItems[i],
                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
               ),
            ),
          ),
      ],
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
                         if (group.imageUrl != null) Image.network(group.imageUrl!, height: 50),
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
            child: SvgPicture.network(
              item.content,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              placeholderBuilder: (c) => const Icon(Icons.image, size: 40),
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
        child: Image.network(
          item.content,
          width: 80,
          height: 80,
          fit: BoxFit.contain,
          errorBuilder: (c,e,s) => const Icon(Icons.broken_image, size: 40),
        ),
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
        child: SvgPicture.string(
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
                  child: images[0].imageUrl?.toLowerCase().endsWith('.svg') == true
                    ? SvgPicture.network(
                        images[0].imageUrl!,
                        fit: BoxFit.contain,
                        placeholderBuilder: (c) => Container(color: Colors.grey.shade200),
                      )
                    : Image.network(
                        images[0].imageUrl ?? "",
                        fit: BoxFit.contain,
                        errorBuilder: (c,e,s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
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
                     child: img.imageUrl?.toLowerCase().endsWith('.svg') == true
                     ? SvgPicture.network(
                         img.imageUrl!,
                         fit: BoxFit.contain,
                         placeholderBuilder: (c) => Container(color: Colors.grey.shade200),
                       )
                     : Image.network(
                       img.imageUrl ?? "",
                       fit: BoxFit.cover,
                       errorBuilder: (c,e,s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
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

  Widget _buildImageOptions(WidgetRef ref, List<RichOption> options, int? selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = options.length >= 4 ? 2 : 2;
          // If we have 3 items, maybe use 3 columns if screen is wide enough, else 2.
          // Let's stick to 2 for mobile-friendliness unless > 600px
          if (constraints.maxWidth > 500 && options.length >= 3) {
            crossAxisCount = 3;
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9, // Taller for Text + Image
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
               final opt = options[index];
               final isSelected = selected == index;
               return GestureDetector(
                 onTap: () => ref.read(practiceProvider(skillId).notifier).selectOption(index),
                 child: Container(
                   decoration: BoxDecoration(
                     border: Border.all(
                        color: isSelected ? AppColors.primaryGreen : Colors.lightBlue.shade100,
                        width: isSelected ? 4 : 2, 
                     ),
                     borderRadius: BorderRadius.circular(12),
                     color: Colors.white,
                   ),
                   child: Column(
                     children: [
                       Expanded(
                         child: Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: ClipRRect(
                             borderRadius: BorderRadius.circular(8),
                             child: opt.imageUrl != null 
                             ? (opt.imageUrl!.toLowerCase().endsWith('.svg') 
                                ? SvgPicture.network(
                                    opt.imageUrl!,
                                    fit: BoxFit.contain,
                                    placeholderBuilder: (c) => const Center(child: Icon(Icons.image, color: Colors.grey)),
                                  )
                                : Image.network(
                                  opt.imageUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (c,e,s) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                ))
                             : const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                           ),
                         ),
                       ),
                       if (opt.text != null && opt.text!.isNotEmpty)
                         Container(
                           width: double.infinity,
                           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                           color: isSelected ? AppColors.lightGreen : Colors.blue.shade50,
                           child: Text(
                             opt.text!,
                             textAlign: TextAlign.center,
                             style: TextStyle(
                               fontWeight: FontWeight.bold, 
                               fontSize: 16,
                               color: isSelected ? AppColors.darkGreen : AppColors.textPrimary
                             ),
                           ),
                         ),
                     ],
                   ),
                 ),
               );
            },
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
