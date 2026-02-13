import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../practice_controller.dart';
import 'package:gap/gap.dart';

class PracticeSidebar extends ConsumerWidget {
  final String skillId;
  const PracticeSidebar({super.key, required this.skillId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(practiceProvider(skillId));

    // Format timer
    final hours = state.elapsedTime.inHours.toString().padLeft(2, '0');
    final minutes = state.elapsedTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = state.elapsedTime.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Container(
      width: 250,
      color: Colors.white, // Or slightly off-white if needed
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Questions Answered Box
          _buildBox(
            header: "Questions\nanswered",
            headerColor: const Color(0xFF8CC63F), // IXL Green
            content: Text(
              '${state.questionsAnswered}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF555555)),
            ),
          ),
          const Gap(16),

           // Time Elapsed Box
          _buildBox(
            header: "Time\nelapsed",
            headerColor: const Color(0xFF27A9E1), // IXL Blue
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeUnit(hours, "HR"),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text(":", style: TextStyle(color: Colors.grey))),
                _buildTimeUnit(minutes, "MIN"),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text(":", style: TextStyle(color: Colors.grey))),
                _buildTimeUnit(seconds, "SEC"),
              ],
            ),
          ),
          
          const Gap(16),

          // SmartScore Box / Challenge
          // The image shows "Challenge Stage 1 of 2".
          // We'll mimic this layout but use SmartScore if challenge data isn't available.
          // Or just standard SmartScore box. 
          // The USER image shows "Challenge" box which is ORANGE.
          
          _buildBox(
            header: "SmartScore",
            headerColor: const Color(0xFFF16434), // IXL Orange
            content: Column(
              children: [
                Text(
                  '${state.smartScore}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF555555)),
                ),
                // Pseudo Challenge progress
                const Gap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Icon(Icons.circle, size: 12, color: state.questionsAnswered > 0 ? const Color(0xFFFFC107) : Colors.grey.shade300),
                     const Gap(4),
                     Icon(Icons.circle, size: 12, color: state.questionsAnswered > 4 ? const Color(0xFFFFC107) : Colors.grey.shade300),
                     const Gap(4),
                     Icon(Icons.circle, size: 12, color: state.questionsAnswered > 8 ? const Color(0xFFFFC107) : Colors.grey.shade300),
                  ],
                )
              ]
            ),
          ),

          const Spacer(),
          
          TextButton.icon(
            onPressed: (){}, 
            icon: const Icon(Icons.bolt, size: 16),
            label: const Text("Teacher tools >"),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
          ),
          
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {},
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String val, String label) {
    return Column(
      children: [
        Container(
           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
           decoration: BoxDecoration(
             color: Colors.grey.shade100,
             border: Border.all(color: Colors.grey.shade300),
             borderRadius: BorderRadius.circular(4),
           ),
           child: Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
        ),
        const Gap(2),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBox({required String header, required Color headerColor, required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4), // Sharp-ish corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            color: headerColor,
            child: Text(
              header,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, height: 1.1),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(child: content),
          )
        ],
      ),
    );
  }
}
