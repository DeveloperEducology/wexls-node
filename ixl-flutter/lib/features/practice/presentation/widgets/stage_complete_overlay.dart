import 'package:flutter/material.dart';

class StageCompleteOverlay extends StatelessWidget {
  final int nextStage;
  final VoidCallback onContinue;

  const StageCompleteOverlay({
    super.key,
    required this.nextStage,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.98),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Title
          const Text(
            "Well Done!",
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900, // Very bold
              color: Color(0xFF7CB342), // Green
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 40),

          // Central Card / Graphic
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                 BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                 ),
              ],
            ),
            child: Column(
              children: [
                 // Arrow Shape / Header for Next Stage
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                   decoration: const BoxDecoration(
                     color: Color(0xFF039BE5), // Blue
                     borderRadius: BorderRadius.horizontal(right: Radius.circular(50)), // Arrow-ish
                   ),
                   child: Text(
                     "Stage $nextStage",
                     style: const TextStyle(
                       color: Colors.white,
                       fontWeight: FontWeight.bold,
                       fontSize: 18,
                     ),
                   ),
                 ),
                 const SizedBox(height: 16),
                 const Text(
                   "Get 3 correct in a row",
                   textAlign: TextAlign.center,
                   style: TextStyle(
                     fontSize: 18,
                     fontWeight: FontWeight.w500,
                     color: Colors.black87,
                   ),
                 ),
              ],
            ),
          ),
          
          const Spacer(flex: 3),
          
          // Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7CB342),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
