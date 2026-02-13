import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AIReviewScreen extends StatelessWidget {
  final List<dynamic> aiData;
  final String topic;

  const AIReviewScreen({Key? key, required this.aiData, required this.topic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("AI Review: $topic"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: aiData.length,
        itemBuilder: (context, index) {
          final q = aiData[index];
          return Card(
            margin: EdgeInsets.only(bottom: 20),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Question ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  SizedBox(height: 8),
                   Text(q['question'], style: TextStyle(fontSize: 16)),
                  if (q['math'] != null && q['math'].toString().isNotEmpty) ...[
                     SizedBox(height: 8),
                     Math.tex(q['math'], textStyle: TextStyle(fontSize: 18)),
                  ],
                  if (q['diagram'] != null && q['diagram'].toString().contains('<svg')) ...[
                    SizedBox(height: 12),
                    Center(
                      child: SvgPicture.string(
                        q['diagram'],
                        height: 150,
                        placeholderBuilder: (context) => const CircularProgressIndicator(),
                      ),
                    ),
                  ],
                  SizedBox(height: 16),
                  Divider(),
                  Text("Solution:", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  if (q['steps'] != null)
                    ...(q['steps'] as List).map((s) => Text("• $s", style: TextStyle(color: Colors.grey[800]))),
                  if (q['exp_math'] != null && q['exp_math'].toString().isNotEmpty)
                     Math.tex(q['exp_math'], textStyle: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
