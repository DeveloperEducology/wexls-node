import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/data_models.dart';
import '../widgets/home_widgets.dart';
import 'quiz_screen.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../services/supabase_service.dart';
import 'subject_details_screen.dart';
import 'profile_screen.dart';
import 'learn_screen.dart';
import 'tests_screen.dart';
import 'ai_quiz_launcher_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  bool _isLoading = true;
  List<Test> upcomingTests = [];
  String _userName = "Learner";

  List<Subject> subjects = [];
  
  List<Activity> recentActivities = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final service = SupabaseService();
      
      // 1. Fetch User Profile
      final profile = await service.getUserProfile();
      String? targetClass;
      List<String>? categories; // Assuming simple list of strings for now from JSON
      
      if (profile != null) {
        setState(() => _userName = profile['full_name'] ?? 'Learner');
        targetClass = profile['user_class'];
        // categories = ... parsing logic if it's a JSON array or text array. 
        // For now, let's rely on target_class as primary filter or categories if class is null.
      }

      // 2. Fetch Tests based on profile
      final data = await service.getTestSeries(targetClass: targetClass);
      
      // 3. Fetch Subjects
      final subjectsData = await service.getSubjects();

      // 4. Fetch Recent Activity
      final activityData = await service.getRecentActivities();

      if (mounted) {
        setState(() {
          upcomingTests = data.map((e) => Test.fromJson(e)).toList();
          subjects = subjectsData.map((e) => Subject.fromJson(e)).toList();
          recentActivities = activityData.map((e) => Activity.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Choose body based on index
    Widget bodyContent;
    switch (_currentIndex) {
      case 0:
        bodyContent = _buildHomeContent();
        break;
      case 4:
        bodyContent = ProfileScreen();
        break;
      case 1:
        bodyContent = LearnScreen();
        break;
      case 2:
        bodyContent = TestsScreen();
        break;
      default:
        bodyContent = Center(child: Text("Coming Soon", style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)));

    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: bodyContent,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF0052D4),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: "Learn"),
          BottomNavigationBarItem(icon: Icon(Icons.quiz_rounded), label: "Tests"),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard_rounded), label: "Rank"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 24),
          ProgressCard(),
          SizedBox(height: 24),
          _buildQuickActions(),
          SizedBox(height: 24),
          _buildSectionHeader("Subjects", "View All"),
          SizedBox(height: 16),
          _buildSubjectsGrid(),
          SizedBox(height: 24),
          _buildSectionHeader("Upcoming Tests", "Scheduled"),
          SizedBox(height: 16),
          Container(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: upcomingTests.length,
              itemBuilder: (context, index) {
                final test = upcomingTests[index];
                return UpcomingTestCard(
                  test: test,
                  onStart: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (c) => Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final service = SupabaseService();
                      final qData = await service.getQuestionsForTest(test.id);
                      
                      if (qData.isEmpty) {
                        Navigator.pop(context); 
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No questions found for this test.")));
                        return;
                      }

                      final questions = qData.map((e) => Question.fromJson(e)).toList();
                      
                      if (!context.mounted) return;
                      
                      context.read<QuizProvider>().loadQuestions(questions);
                      context.read<QuizProvider>().startQuiz(QuizMode.exam, durationSeconds: test.duration * 60);
                      
                      Navigator.pop(context); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuizScreen()),
                      );

                    } catch (e) {
                      Navigator.pop(context); 
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load test: $e")));
                    }
                  },
                );
              },
            ),
          ),
          SizedBox(height: 24),
          _buildSectionHeader("Recent Activity", "History"),
          SizedBox(height: 16),
          ...recentActivities.map((e) => RecentActivityItem(activity: e)).toList(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
              backgroundColor: Colors.grey[200],
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, $_userName!",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Let's start learning",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Icon(Icons.search, color: Colors.black87),
            ),
            SizedBox(width: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Icon(Icons.notifications_none, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          QuickActionItem(
            icon: Icons.assignment_outlined,
            label: "Practice",
            color: Color(0xFF6C63FF),
            onTap: () {
               context.read<QuizProvider>().loadQuestions(Quiz.sampleData);
               context.read<QuizProvider>().startQuiz(QuizMode.practice);
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuizScreen()),
              );
            },
          ),
          QuickActionItem(
             icon: Icons.timer_outlined,
            label: "Mock Test",
            color: Color(0xFFFF6584),
            onTap: () {
              // JEE Maths Mock
               context.read<QuizProvider>().loadQuestions(Quiz.jeeMathsMock);
               context.read<QuizProvider>().startQuiz(QuizMode.exam);
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuizScreen()),
              );
            },
          ),
          QuickActionItem(
             icon: Icons.auto_awesome_rounded,
            label: "AI Room",
            color: Color(0xFF9C27B0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIQuizLauncherPage()),
              );
            },
          ),
           QuickActionItem(
            icon: Icons.emoji_events_outlined,
            label: "Rank",
            color: Color(0xFF29C7AC),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          action,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0052D4),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubjectDetailsScreen(subject: subjects[index]),
              ),
            );
          },
          child: SubjectCard(subject: subjects[index]),
        );
      },
    );
  }
}
