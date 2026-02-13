import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../models/data_models.dart';
import '../widgets/content_renderer.dart';
import '../services/supabase_service.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final int totalTimeSeconds;
  final Map<int, int> selectedAnswers;
  final List<Question> questions;
  final String testTitle;
  final String testType; // 'practice' or 'exam'

  const ResultScreen({
    required this.score,
    required this.totalQuestions,
    required this.totalTimeSeconds,
    required this.selectedAnswers,
    required this.questions,
    this.testTitle = "Practice Quiz",
    this.testType = "practice",
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    // Determine pass/fail (e.g., > 40%)
    bool passed = (widget.score / widget.totalQuestions) >= 0.4;
    
    await SupabaseService().saveActivity(
      title: widget.testTitle,
      type: widget.testType,
      score: widget.score,
      totalScore: widget.totalQuestions, // Assuming 1 mark per question for simplicty in summary
      passed: passed,
    );
  }

  @override
  Widget build(BuildContext context) {
    double percentage = widget.score / widget.totalQuestions;
    
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Quiz Analysis", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(), // Go back to Home
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Score Board
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 80.0,
                    lineWidth: 12.0,
                    percent: percentage.isNaN ? 0.0 : percentage,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${(percentage * 100).toInt()}%", style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF0052D4))),
                        Text("Score", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                    progressColor: Color(0xFF0052D4),
                    backgroundColor: Colors.grey[100]!,
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("Correct", "${widget.score}", Colors.green),
                      _buildStatItem("Wrong", "${widget.totalQuestions - widget.score}", Colors.red),
                      _buildStatItem("Time", _formatTime(widget.totalTimeSeconds), Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            
            Align(alignment: Alignment.centerLeft, child: Text("Question Review", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold))),
            SizedBox(height: 16),
            
            // Note: Keeping the rest of the build method same mostly, just accessing widget.properties
            _buildReviewList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.questions.length,
      itemBuilder: (context, index) {
        final question = widget.questions[index];
        final userAnswerIdx = widget.selectedAnswers[index];
        final isCorrect = userAnswerIdx == question.correctOptionIndex;
        final isSkipped = userAnswerIdx == null;

        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: ExpansionTile(
            tilePadding: EdgeInsets.all(16),
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.withOpacity(0.1) : (isSkipped ? Colors.grey.withOpacity(0.1) : Colors.red.withOpacity(0.1)),
                shape: BoxShape.circle,
              ),
              child: Icon(isCorrect ? Icons.check : (isSkipped ? Icons.remove : Icons.close), color: isCorrect ? Colors.green : (isSkipped ? Colors.grey : Colors.red)),
            ),
            title: Text("Question ${index + 1}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            subtitle: Text(isCorrect ? "Correct" : (isSkipped ? "Skipped" : "Incorrect"), style: GoogleFonts.poppins(color: isCorrect ? Colors.green : (isSkipped ? Colors.grey : Colors.red))),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContentRenderer(parts: question.parts),
                    SizedBox(height: 16),
                    Text("Explanation:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(question.explanation, textStyle: GoogleFonts.poppins(fontSize: 14)),
                    ),
                    SizedBox(height: 16),
                    if (!isCorrect && !isSkipped)
                       Row(
                         children: [
                           Text("Your Answer: ", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)),
                           // Handle range error if index invalid, though shouldn't happen logic wise
                           Expanded(child: ContentRenderer(parts: question.options[userAnswerIdx!].parts)), 
                         ],
                       ),
                    Row(
                      children: [
                        Text("Correct Answer: ", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                        Expanded(child: ContentRenderer(parts: question.options[question.correctOptionIndex].parts)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
