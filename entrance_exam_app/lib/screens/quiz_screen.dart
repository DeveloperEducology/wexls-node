import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/data_models.dart';
import '../providers/quiz_provider.dart';
import 'result_screen.dart';
import '../widgets/content_renderer.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(context);
        if (shouldPop) {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
        child: Consumer<QuizProvider>(
          builder: (context, provider, child) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: Color(0xFFF5F7FA),
              endDrawer: _buildDrawer(context, provider), // Changed to endDrawer per request
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      return _buildDesktopLayout(context, provider);
                    } else {
                      return _buildMobileLayout(context, provider);
                    }
                  },
                ),
              ),
            );
          }
        ),
    );
  }
  Future<bool> _showExitConfirmation(BuildContext context) async {
    final provider = context.read<QuizProvider>();
    
    if (provider.mode == QuizMode.practice) {
       return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Finish Practice?"),
          content: Text("Do you want to finish and save your progress?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Stay
              }, 
              child: Text("Cancel")
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Quit
              },
              child: Text("Quit", style: TextStyle(color: Colors.red))
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false); // Close dialog (don't pop screen yet)
                provider.submitQuiz();
                // Navigate to Result
                int timeTaken = 600 - provider.secondsRemaining; 
                 if (provider.startTime != null) {
                    timeTaken = DateTime.now().difference(provider.startTime!).inSeconds;
                 }
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(
                      score: provider.score,
                      totalQuestions: provider.questions.length,
                      totalTimeSeconds: timeTaken,
                      selectedAnswers: provider.selectedAnswers,
                      questions: provider.questions,
                      testTitle: provider.mode == QuizMode.exam ? "Mock Exam" : "Practice Session",
                      testType: provider.mode == QuizMode.exam ? "exam" : "practice",
                    ),
                  ),
                );
              },
              child: Text("Finish & Save"),
            ),
          ],
        ),
      ) ?? false;
    }

    // Exam Mode
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Exit Quiz?"),
        content: Text("Your progress will be lost."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text("Exit")),
        ],
      ),
    ) ?? false;
  }

  Widget _buildMobileLayout(BuildContext context, QuizProvider provider) {
    return Column(
      children: [
        _buildHeader(context, provider),
        _buildProgressBar(provider),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                _buildQuestionContent(provider.questions[provider.currentIndex]),
                SizedBox(height: 24),
                _buildOptions(context, provider),
                if (provider.mode == QuizMode.practice) ...[
                  SizedBox(height: 20),
                  _buildFeedback(provider),
                ],
              ],
            ),
          ),
        ),
        _buildBottomControls(context, provider),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, QuizProvider provider) {
    return Row(
      children: [
        // Main Content
        Expanded(
          child: Column(
            children: [
              _buildHeader(context, provider),
              _buildProgressBar(provider),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuestionContent(provider.questions[provider.currentIndex]),
                      SizedBox(height: 32),
                      _buildOptions(context, provider),
                        if (provider.mode == QuizMode.practice) ...[
                          SizedBox(height: 20),
                          _buildFeedback(provider),
                        ],
                    ],
                  ),
                ),
              ),
              _buildBottomControls(context, provider),
            ],
          ),
        ),
        VerticalDivider(width: 1),
        // Right Panel (Timer & Info)
        Container(
          width: 250,
          color: Colors.white,
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              _buildTimerWidget(provider),
              SizedBox(height: 20),
              Text("Time Remaining", style: GoogleFonts.poppins(color: Colors.grey)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHeader(BuildContext context, QuizProvider provider) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
             icon: Icon(Icons.arrow_back, color: Colors.black),
             onPressed: () => _showExitConfirmation(context).then((shouldExit) {
                  if (shouldExit) Navigator.pop(context);
             }),
          ),
          Column(
            children: [
              Text(
                provider.mode == QuizMode.exam ? "Mock Test" : "Practice",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (provider.mode == QuizMode.practice)
                Row(
                  children: [
                    Icon(Icons.stars_rounded, size: 16, color: Colors.orange),
                    SizedBox(width: 4),
                    Text("Score: ${provider.score}", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                    SizedBox(width: 12),
                    Icon(Icons.local_fire_department_rounded, size: 16, color: Colors.red),
                    SizedBox(width: 4),
                    Text("Streak: ${provider.currentStreak}", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
            ],
          ),
          Row(
            children: [
               _buildTimerWidget(provider),
               if (provider.mode == QuizMode.exam) ...[
                 SizedBox(width: 8),
                 IconButton(
                   icon: Icon(Icons.grid_view_rounded, color: Color(0xFF0052D4)),
                   onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                   tooltip: "Question Palette",
                 ),
               ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerWidget(QuizProvider provider) {
    int totalSeconds = provider.mode == QuizMode.practice 
        ? provider.elapsedSeconds 
        : provider.secondsRemaining;
        
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF0052D4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProgressBar(QuizProvider provider) {
    return LinearProgressIndicator(
      value: (provider.currentIndex + 1) / provider.questions.length,
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation(Color(0xFF0052D4)),
      minHeight: 4,
    );
  }

  Widget _buildQuestionContent(Question question) {
    return ContentRenderer(
      parts: question.parts, 
      textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500)
    );
  }

  Widget _buildOptions(BuildContext context, QuizProvider provider) {
    final question = provider.questions[provider.currentIndex];
    
    if (question.layout == 'grid') {
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0, // More vertical space
        ),
        itemCount: question.options.length,
        itemBuilder: (context, index) => _buildOptionItem(context, provider, index, true),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: question.options.length,
      itemBuilder: (context, index) => _buildOptionItem(context, provider, index, false),
    );
  }

  Widget _buildOptionItem(BuildContext context, QuizProvider provider, int index, bool isGrid) {
        bool isSelected = provider.selectedAnswers[provider.currentIndex] == index;
        bool isCorrect = provider.questions[provider.currentIndex].correctOptionIndex == index;
        bool isChecked = provider.checkedQuestions.contains(provider.currentIndex);
        
        Color borderColor = Colors.grey.withOpacity(0.3);
        Color bgColor = Colors.white;
        Color circleColor = Colors.white;
        Color circleTextColor = Colors.black54;

        if (isChecked && provider.mode == QuizMode.practice) {
             if (isCorrect) {
               borderColor = Colors.green;
               bgColor = Colors.green.withOpacity(0.1);
               circleColor = Colors.green;
               circleTextColor = Colors.white;
             } else if (isSelected) {
                borderColor = Colors.red;
                bgColor = Colors.red.withOpacity(0.1);
                circleColor = Colors.red;
                circleTextColor = Colors.white;
             } else if (isCorrect) {
                 // Show correct answer even if not selected
                 borderColor = Colors.green.withOpacity(0.5);
             }
        } else if (isSelected) {
           borderColor = Color(0xFF0052D4);
           bgColor = Colors.white;
           circleColor = Color(0xFF0052D4);
           circleTextColor = Colors.white;
        }
        
        // Letter A, B, C, D
        String letter = String.fromCharCode(65 + index);
        
        final option = provider.questions[provider.currentIndex].options[index];

        return GestureDetector(
          onTap: () => provider.selectAnswer(index),
          child: Container(
            margin: isGrid ? EdgeInsets.zero : EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor, width: isSelected || (isChecked && (isCorrect || isSelected)) ? 2 : 1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isSelected ? [BoxShadow(color: Color(0xFF0052D4).withOpacity(0.1), blurRadius: 8, offset: Offset(0, 4))] : [],
            ),
            child: isGrid 
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                      width: 32, height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                        border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3)),
                      ),
                      child: Text(letter, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: circleTextColor)),
                   ),
                   SizedBox(height: 12),
                   Expanded(
                     child: Center(
                       child: ContentRenderer(
                         parts: option.parts,
                         textStyle: GoogleFonts.poppins(fontSize: 14),
                         inline: true,
                       ),
                     ),
                   ),
                ],
              )
            : Row(
              children: [
                 Container(
                    width: 40, height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: circleColor,
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3)),
                    ),
                    child: Text(letter, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: circleTextColor)),
                 ),
                 SizedBox(width: 16),
                 Expanded(
                   child: ContentRenderer(
                     parts: option.parts,
                     textStyle: GoogleFonts.poppins(fontSize: 16, height: 1.5, color: Colors.black87),
                   )
                 ),
              ],
            ),
          ),
        );
  }

  Widget _buildFeedback(QuizProvider provider) {
     if (!provider.checkedQuestions.contains(provider.currentIndex)) return SizedBox.shrink();

     final question = provider.questions[provider.currentIndex];
     bool isCorrect = provider.selectedAnswers[provider.currentIndex] == question.correctOptionIndex;

     return Container(
       padding: EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: isCorrect ? Colors.green : Colors.red),
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            Text(isCorrect ? "Correct!" : "Incorrect", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isCorrect ? Colors.green : Colors.red)),
            SizedBox(height: 8),
            Text("Explanation:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Math.tex(
                  question.explanation,
                  textStyle: TextStyle(fontSize: 14),
                  onErrorFallback: (e) => Text(question.explanation),
              ),
            )
         ],
       ),
     );
  }

  Widget _buildBottomControls(BuildContext context, QuizProvider provider) {
    // Practice Mode Controls
    if (provider.mode == QuizMode.practice) {
       bool isChecked = provider.checkedQuestions.contains(provider.currentIndex);
       
       return Container(
         padding: EdgeInsets.all(16),
         decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))
          ]
        ),
         child: SizedBox(
           width: double.infinity,
           child: ElevatedButton(
             onPressed: () {
               if (!isChecked) {
                 // Check Answer
                 if (provider.selectedAnswers.containsKey(provider.currentIndex)) {
                    provider.checkAnswer();
                 } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select an answer first")));
                 }
               } else {
                 // Next Question
                 if (provider.currentIndex < provider.questions.length - 1) {
                   provider.nextQuestion();
                 } else {
                   _showResultSummary(context, provider);
                 }
               }
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: isChecked ? Color(0xFF00C853) : Colors.orange,
               padding: EdgeInsets.symmetric(vertical: 16),
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             ),
             child: Text(
               isChecked 
                  ? (provider.currentIndex < provider.questions.length - 1 ? "Next Question" : "Finish Practice")
                  : "Check Answer",
               style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
             ),
           ),
         ),
       );
    }

    // Exam/Mock Mode Controls
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, -5))
        ]
      ),
      child: Column(
        children: [
          // Mark for Review Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => provider.toggleMarkForReview(),
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.markedForReview.contains(provider.currentIndex) 
                    ? Colors.orange 
                    : Colors.white,
                side: provider.markedForReview.contains(provider.currentIndex) 
                    ? BorderSide.none
                    : BorderSide(color: Colors.orange),
                padding: EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                provider.markedForReview.contains(provider.currentIndex) 
                    ? "Unmark Review" 
                    : "Mark for Review",
                style: GoogleFonts.poppins(color: provider.markedForReview.contains(provider.currentIndex) ? Colors.white : Colors.orange, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 12),
          
          // Navigation Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Expanded(
                 child: OutlinedButton(
                   onPressed: provider.currentIndex > 0 ? provider.prevQuestion : null,
                   style: OutlinedButton.styleFrom(
                     backgroundColor: Colors.white,
                     side: BorderSide(color: Colors.grey[300]!),
                     padding: EdgeInsets.symmetric(vertical: 12),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   ),
                   child: Text("Previous", style: GoogleFonts.poppins(color: Colors.black87)),
                 ),
               ),
               SizedBox(width: 12),
               Expanded(
                 child: OutlinedButton(
                   onPressed: () {
                      if (provider.currentIndex < provider.questions.length - 1) {
                         provider.nextQuestion();
                      }
                   },
                   style: OutlinedButton.styleFrom(
                     backgroundColor: Colors.white,
                     side: BorderSide(color: Colors.grey[300]!),
                     padding: EdgeInsets.symmetric(vertical: 12),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   ),
                   child: Text("Skip", style: GoogleFonts.poppins(color: Colors.black87)),
                 ),
               ),
               SizedBox(width: 12),
               Expanded(
                 child: ElevatedButton(
                   onPressed: () {
                     if (provider.currentIndex < provider.questions.length - 1) {
                       provider.nextQuestion();
                     } else {
                       _showResultSummary(context, provider);
                     }
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: provider.currentIndex == provider.questions.length - 1 
                        ? Colors.red // Submit color
                        : Color(0xFF00C853), // Next color (Green)
                     padding: EdgeInsets.symmetric(vertical: 12),
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                   ),
                   child: Text(
                     provider.currentIndex == provider.questions.length - 1 ? "Submit" : "Next",
                     style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                   ),
                 ),
               ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showResultSummary(BuildContext context, QuizProvider provider) {
     int answered = provider.selectedAnswers.length;
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text("Submit Session?"),
         content: Text("You have answered $answered of ${provider.questions.length} questions."),
         actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                provider.submitQuiz(); // Mark as finished (stops timer)
                
                // Navigate to Result Screen
                // Calculate time taken manually since we just have secondsRemaining
                int timeTaken = 600 - provider.secondsRemaining; 
                if (provider.startTime != null) {
                    timeTaken = DateTime.now().difference(provider.startTime!).inSeconds;
                }
                
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(
                      score: provider.score,
                      totalQuestions: provider.questions.length,
                      totalTimeSeconds: provider.elapsedSeconds,
                      selectedAnswers: provider.selectedAnswers,
                      questions: provider.questions,
                      testTitle: provider.mode == QuizMode.exam ? "Mock Exam" : "Practice Quiz",
                      testType: provider.mode == QuizMode.exam ? "exam" : "practice",
                    ),
                  ),
                );
              },
              child: Text("Submit"),
            ),
         ],
       ),
     );
  }

  Widget _buildDrawer(BuildContext context, QuizProvider provider) {
    int answered = provider.selectedAnswers.length;
    // int marked = provider.markedForReview.length; 

    return Drawer(
      width: 300,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Theory Questions", style: GoogleFonts.poppins(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Question : ${provider.currentIndex + 1}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          Expanded(child: _buildQuestionGrid(provider)),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem(Colors.green, "Answered"),
                    _buildLegendItem(Colors.red, "Not Answered"),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem(Colors.orange, "Review"),
                    _buildLegendItem(Colors.grey[300]!, "Not Visited"),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        SizedBox(width: 8),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  Widget _buildQuestionGrid(QuizProvider provider) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: provider.questions.length,
      itemBuilder: (context, index) {
        bool isCurrent = provider.currentIndex == index;
        bool isAnswered = provider.selectedAnswers.containsKey(index);
        bool isMarked = provider.markedForReview.contains(index);
        
        Color bgColor = Colors.white;
        Color textColor = Colors.black87;
        Color borderColor = Colors.grey[300]!;
        
        if (isMarked) {
          bgColor = Colors.orange;
          textColor = Colors.white;
          borderColor = Colors.orange;
        } else if (isAnswered) {
          bgColor = Colors.green;
          textColor = Colors.white;
          borderColor = Colors.green;
        } else if (isCurrent) {
           borderColor = Colors.black; 
        } 
        
        return GestureDetector(
          onTap: () {
            provider.jumpToQuestion(index);
            Navigator.pop(context); // Close drawer on selection
          },
          child: Container(
             alignment: Alignment.center,
             decoration: BoxDecoration(
               color: bgColor,
               shape: BoxShape.circle,
               border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
             ),
             child: Text(
               "${index + 1}",
               style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold),
             ),
          ),
        );
      },
    );
  }
}
