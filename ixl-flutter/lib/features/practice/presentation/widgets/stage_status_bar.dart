import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class StageStatusBar extends StatelessWidget {
  final int currentStage; // Legacy, kept for compatibility if needed
  final int totalStages;
  final int stageStreak;
  final int goal;
  final bool isChallengeZone;
  final int smartScore; // MAIN METRIC

  const StageStatusBar({
    super.key,
    required this.currentStage,
    required this.totalStages,
    required this.stageStreak,
    required this.goal,
    this.isChallengeZone = false,
    this.smartScore = 0,
  });

  @override
  Widget build(BuildContext context) {
    Color barColor = const Color(0xFF7CB342); // Green (default)
    Color bgColor = Colors.white;
    String statusText = "Practice";
    IconData statusIcon = Icons.edit;
    
    // Determine Zone
    if (smartScore >= 90) {
       barColor = Colors.deepOrange; // Challenge
       bgColor = const Color(0xFFFFF3E0);
       statusText = "CHALLENGE ZONE";
       statusIcon = Icons.local_fire_department;
    } else if (smartScore >= 80) {
       barColor = const Color(0xFF1E88E5); // Blue
       statusText = "Excellence";
       statusIcon = Icons.star;
    } else if (smartScore >= 70) {
       barColor = const Color(0xFF8E24AA); // Purple
       statusText = "Proficiency";
       statusIcon = Icons.emoji_events;
    }

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced vertical padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(
                      "SmartScore: $smartScore", 
                      style: TextStyle(
                        fontSize: 18, // Slightly smaller font
                        fontWeight: FontWeight.bold,
                        color: barColor,
                      ),
                    ),
                    if (isChallengeZone)
                      const Text(
                        "Double Jeopardy!", 
                        style: TextStyle(fontSize: 10, color: Colors.deepOrange)
                      ),
                 ],
               ),
               
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                 decoration: BoxDecoration(
                   color: barColor.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(20),
                 ),
                 child: Row(
                   children: [
                     Icon(statusIcon, size: 14, color: barColor),
                     const SizedBox(width: 4),
                     Text(
                       statusText,
                       style: TextStyle(
                         color: barColor,
                         fontWeight: FontWeight.bold,
                         fontSize: 11,
                       ),
                     ),
                   ],
                 ),
               )
            ],
          ),
          
          const SizedBox(height: 6), // Reduced gap
          
          // Progress Bar with Milestones
          SizedBox(
            height: 18, // Reduced total height
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxWidth = constraints.maxWidth;
                
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Background Track
                    Container(
                      height: 8, // Thinner track
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Fill
                    Container(
                      height: 8, // Thinner fill
                      width: maxWidth * (smartScore / 100),
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    
                    // Milestones (70, 80, 90)
                    _buildMilestoneMarker(70, smartScore, Colors.purple, maxWidth),
                    _buildMilestoneMarker(80, smartScore, Colors.blue, maxWidth),
                    _buildMilestoneMarker(90, smartScore, Colors.deepOrange, maxWidth),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneMarker(int position, int currentScore, Color color, double totalWidth) {
      final double left = totalWidth * (position / 100.0) - 8; // Center the 16px icon (was 20)
      bool achieved = currentScore >= position;
      
      return Positioned(
        left: left,
        child: Container(
          width: 16, // Smaller marker
          height: 16,
          decoration: BoxDecoration(
            color: achieved ? color : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              if (achieved)
                BoxShadow(color: color.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)
            ]
          ),
          child: achieved 
            ? const Icon(Icons.star, size: 10, color: Colors.white)
            : Center(child: Text("$position", style: const TextStyle(fontSize: 7, color: Colors.white))),
        ),
      );
  }
}
