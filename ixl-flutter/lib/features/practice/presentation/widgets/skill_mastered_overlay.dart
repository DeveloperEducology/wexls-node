import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class SkillMasteredOverlay extends StatefulWidget {
  final VoidCallback onFinish;

  const SkillMasteredOverlay({
    super.key,
    required this.onFinish,
  });

  @override
  State<SkillMasteredOverlay> createState() => _SkillMasteredOverlayState();
}

class _SkillMasteredOverlayState extends State<SkillMasteredOverlay> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 120, color: Colors.amber),
              const SizedBox(height: 24),
              const Text(
                "Skill Mastered!",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A52E),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "You have completed all stages.",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A52E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Back to Dashboard", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
            gravity: 0.3,
          ),
        ),
      ],
    );
  }
}
