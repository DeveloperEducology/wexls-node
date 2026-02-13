import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/data_models.dart';

class ContentRenderer extends StatelessWidget {
  final List<QuestionPart> parts;
  final TextStyle? textStyle;
  final bool inline; // If true, tries to wrap content tightly

  const ContentRenderer({
    required this.parts,
    this.textStyle,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context) {
    // For now, simpler implementation: Column or Wrap
    // Ideally we want text mixed with inline math.
    // Simplifying: If multiple parts, we use a Column of chunks.
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((part) => _buildPart(part)).toList(),
    );
  }

  Widget _buildPart(QuestionPart part) {
    switch (part.type) {
      case QuestionPartType.text:
        // Attempt to parse simple inline math if enabled? For now just text.
        return Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Text(part.content, style: textStyle ?? GoogleFonts.poppins(fontSize: 16)),
        );
      case QuestionPartType.math:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Math.tex(
              part.content,
              textStyle: textStyle?.copyWith(fontSize: (textStyle?.fontSize ?? 16) + 2) ?? TextStyle(fontSize: 18),
              onErrorFallback: (e) => Text(part.content),
            ),
          ),
        );
      case QuestionPartType.diagram: // Assuming SVG string
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
               // Constraint height for grid views
               double maxHeight = inline ? 90 : 150;
               return Container(
                 constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: constraints.maxWidth),
                 child: SvgPicture.string(
                    part.content, 
                    placeholderBuilder: (_) => Container(color: Colors.grey[200], child: Center(child: Icon(Icons.image, size: 24, color: Colors.grey))),
                    fit: BoxFit.contain,
                 ),
               );
            }
          ),
        );
      case QuestionPartType.image:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
               // If inline/grid, use more flexible constraints
               double maxHeight = inline ? 100 : 200; 
               return ConstrainedBox(
                 constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: constraints.maxWidth),
                 child: Image.network(
                   part.content, 
                   fit: BoxFit.contain,
                   errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 40, color: Colors.grey),
                   loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator(strokeWidth: 2));
                   },
                 ),
               );
            }
          ),
        );
    }
  }
}
