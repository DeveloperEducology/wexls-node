import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../services/supabase_service.dart';
import '../providers/quiz_provider.dart';
import '../widgets/home_widgets.dart'; // Reusing UpcomingTestCard style or creating similar
import 'quiz_screen.dart';

class TestsScreen extends StatefulWidget {
  @override
  _TestsScreenState createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Test> _mockTests = [];
  List<Test> _previousPapers = [];
  String? _userClass;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTests();
  }

  Future<void> _fetchTests() async {
    try {
      final service = SupabaseService();
      final profile = await service.getUserProfile();
      String? targetClass = profile?['user_class'];

      // Fetch Mock Tests
      final mocksData = await service.getTestSeries(targetClass: targetClass, type: 'mock');
      
      // Fetch Previous Papers
      final papersData = await service.getTestSeries(targetClass: targetClass, type: 'previous');

      if (mounted) {
        setState(() {
          _userClass = targetClass;
          _mockTests = mocksData.map((e) => Test.fromJson(e)).toList();
          _previousPapers = papersData.map((e) => Test.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print("Error fetching tests: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Test Series",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF0052D4),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF0052D4),
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: "Mock Tests"),
            Tab(text: "Previous Papers"),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTestList(_mockTests, "No mock tests available for $_userClass"),
                _buildTestList(_previousPapers, "No previous papers available for $_userClass"),
              ],
            ),
    );
  }

  Widget _buildTestList(List<Test> tests, String emptyMessage) {
    if (tests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_outlined, size: 60, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(emptyMessage, style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return UpcomingTestCard(
          test: test,
          onStart: () => _startTest(test),
        );
      },
    );
  }

  Future<void> _startTest(Test test) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => Center(child: CircularProgressIndicator()),
    );

    try {
      final service = SupabaseService();
      final qData = await service.getQuestionsForTest(test.id);

      if (!mounted) return;
      Navigator.pop(context); // Hide loading

      if (qData.isEmpty) {
        if (Quiz.sampleData.isNotEmpty) {
           // Fallback to sample
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Using sample questions (Test empty in DB)")));
           context.read<QuizProvider>().loadQuestions(Quiz.sampleData);
        } else {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No questions found for this test.")));
           return;
        }
      } else {
         final questions = qData.map((e) => Question.fromJson(e)).toList();
         context.read<QuizProvider>().loadQuestions(questions);
      }

      // Start Quiz
      context.read<QuizProvider>().startQuiz(
         QuizMode.exam, 
         durationSeconds: test.duration > 0 ? test.duration * 60 : 3600 // Default 1 hour if 0
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QuizScreen()),
      );

    } catch (e) {
      if (mounted) Navigator.pop(context); // Hide loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error starting test: $e")));
    }
  }
}
