import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/models.dart';
import '../practice_controller.dart';

class MeasureView extends ConsumerStatefulWidget {
  final String skillId;
  const MeasureView({super.key, required this.skillId});

  @override
  ConsumerState<MeasureView> createState() => _MeasureViewState();
}

class _MeasureViewState extends ConsumerState<MeasureView> {
  // Ruler Position Logic
  double _rulerX = 50.0; // Initial Offset
  double _rulerY = 80.0; // Initial Y
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceProvider(widget.skillId));
    final question = state.currentQuestion!;
    
    // Parse config (default values if missing)
    final config = question.adaptiveConfig ?? {};
    final String unit = config['unit'] ?? 'cm';
    // Base object width (assuming 40px = 1 unit)
    final double baseWidth = (config['object_width'] as num?)?.toDouble() ?? 200.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. The Interactive Canvas
        LayoutBuilder(
          builder: (context, constraints) {
             final maxWidth = constraints.maxWidth;
             
             // Calculate Scale to fit
             // We want at least 40px padding total
             final double desiredWidth = baseWidth + 60; // +60 for visual padding
             double scale = 1.0;
             if (desiredWidth > maxWidth) {
                scale = maxWidth / desiredWidth;
             }
             
             final double effectiveLineLength = baseWidth * scale;
             final double pixelsPerUnit = 40.0 * scale; 
             
             // Center the line
             final double lineLeft = (maxWidth - effectiveLineLength) / 2;

             return Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Stack(
                children: [
                  // 1.1 The Object to Measure (Fixed & Centered)
                  Positioned(
                     left: lineLeft, 
                     top: 100,
                     child: Container(
                       height: 4 * scale, // Scale thickness too lightly
                       width: effectiveLineLength, 
                       color: Colors.black,
                     ),
                  ),
                  Positioned(
                     left: lineLeft,
                     top: 90, // Start Cap
                     child: Container(width: 2, height: 24, color: Colors.black),
                  ),
                  Positioned(
                     left: lineLeft + effectiveLineLength,
                     top: 90, // End Cap
                     child: Container(width: 2, height: 24, color: Colors.black),
                  ),

                  // 1.2 The Draggable Ruler
                  Positioned(
                    left: _rulerX,
                    top: _rulerY,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                           _rulerX += details.delta.dx;
                           _rulerY += details.delta.dy;
                        });
                      },
                      child: _buildRulerWidget(scale, pixelsPerUnit),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
        
        const Gap(24),
        
        // 2. The Question Prompt & Input
        Row(
           children: [
              const Icon(Icons.volume_up, color: AppColors.primaryGreen),
              const Gap(8),
              Expanded(
                 child: Text(
                    "The line is about ____ $unit long.",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                 ), 
              ),
           ],
        ),
        const Gap(16),
        
        // 3. Input Field
        Row(
          children: [
             SizedBox(
               width: 100,
               child: TextField(
                 onChanged: (val) {
                    // Update Answer in Controller
                    ref.read(practiceProvider(widget.skillId).notifier).setTextInput(val);
                 },
                 keyboardType: TextInputType.number,
                 decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                 ),
                 style: const TextStyle(fontSize: 18),
               ),
             ),
             const Gap(8),
             Text(unit, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildRulerWidget(double scale, double pixelsPerUnit) {
    // Physical ruler width should cover 10 units roughly
    // 10 units * pixelsPerUnit + padding
    final double rulerWidth = (10 * pixelsPerUnit) + 40;

    return Container(
      width: rulerWidth, 
      height: 80,
      decoration: BoxDecoration(
         color: const Color(0xFFE4C488), // Wood color
         borderRadius: BorderRadius.circular(4),
         boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(2,2))
         ]
      ),
      child: CustomPaint(
         painter: RulerPainter(pixelsPerUnit: pixelsPerUnit),
      ),
    );
  }
}

class RulerPainter extends CustomPainter {
  final double pixelsPerUnit;
  RulerPainter({required this.pixelsPerUnit});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.8)
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Start drawing a bit inward
    final double startPad = 20.0;
    
    for (int i = 0; i <= 10; i++) {
        double x = startPad + (i * pixelsPerUnit); 
        
        if (x > size.width - 10) break; // Don't draw off edge

        // Major Tick
        canvas.drawLine(Offset(x, 0), Offset(x, 30), paint);
        
        // Number
        textPainter.text = TextSpan(
           text: "$i", 
           style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width/2, 35));

        if (i < 10) {
           // Half Tick (.5)
           canvas.drawLine(Offset(x + pixelsPerUnit/2, 0), Offset(x + pixelsPerUnit/2, 20), paint);
        }
    }
  }

  @override
  bool shouldRepaint(covariant RulerPainter oldDelegate) {
    return oldDelegate.pixelsPerUnit != pixelsPerUnit;
  }
}
