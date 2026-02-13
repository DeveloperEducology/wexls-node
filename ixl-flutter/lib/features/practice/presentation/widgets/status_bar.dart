import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../practice_controller.dart';

class PracticeStatusBar extends ConsumerWidget {
  final String skillId;
  const PracticeStatusBar({super.key, required this.skillId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(practiceProvider(skillId));
    
    // Format timer
    final minutes = state.elapsedTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = state.elapsedTime.inSeconds.remainder(60).toString().padLeft(2, '0');

    // Smart Score Color
    Color scoreColor = AppColors.scoreRed;
    if (state.smartScore >= 80) {
      scoreColor = AppColors.scoreGreen;
    } else if (state.smartScore >= 50) {
      scoreColor = AppColors.scoreOrange;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStat('Questions', '${state.questionsAnswered}'),
          _buildStat('Time', '$minutes:$seconds'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: scoreColor,
              borderRadius: BorderRadius.circular(8), // Softer corners
              boxShadow: [
                BoxShadow(
                   color: scoreColor.withOpacity(0.3),
                   blurRadius: 4,
                   offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'SmartScore',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                      if (state.smartScore >= 100) ...[
                         const Text('🏆 ', style: TextStyle(fontSize: 16)),
                      ] else if (state.smartScore >= 90) ...[
                         const Text('🥇 ', style: TextStyle(fontSize: 16)),
                      ] else if (state.smartScore >= 80) ...[
                         const Text('🥈 ', style: TextStyle(fontSize: 16)),
                      ] else if (state.smartScore >= 70) ...[
                         const Text('🥉 ', style: TextStyle(fontSize: 16)),
                      ],
                      Text(
                        '${state.smartScore}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                   ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
