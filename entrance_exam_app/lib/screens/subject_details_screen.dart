import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../models/data_models.dart';
import '../providers/quiz_provider.dart';
import '../services/supabase_service.dart';
import 'quiz_screen.dart';

class SubjectDetailsScreen extends StatefulWidget {
  final Subject subject;

  const SubjectDetailsScreen({Key? key, required this.subject}) : super(key: key);

  @override
  _SubjectDetailsScreenState createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  bool _isLoading = true;
  List<Unit> units = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await SupabaseService().getUnitsForSubject(widget.subject.name);
      if (data.isNotEmpty) {
        setState(() {
          units = data.map((e) => Unit.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        // Fallback to sample data
        setState(() {
          units = Unit.getSampleUnits(widget.subject.name);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching units: $e");
      // Fallback
      if (mounted) {
        setState(() {
           units = Unit.getSampleUnits(widget.subject.name);
           _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: widget.subject.color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.subject.name,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.subject.color.withOpacity(0.8), widget.subject.color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(widget.subject.icon, size: 80, color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Learning Units",
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 16),
                  if (_isLoading)
                     Center(child: CircularProgressIndicator())
                  else if (units.isEmpty)
                     Center(child: Text("No content available yet."))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: units.length,
                      itemBuilder: (context, index) {
                        return _UnitCard(unit: units[index], color: widget.subject.color);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final Unit unit;
  final Color color;

  const _UnitCard({required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(
            unit.title,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          subtitle: Text(
            unit.description,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
          children: unit.microSkills.map((skill) => _MicroSkillTile(skill: skill, color: color)).toList(),
        ),
      ),
    );
  }
}

class _MicroSkillTile extends StatelessWidget {
  final MicroSkill skill;
  final Color color;

  const _MicroSkillTile({required this.skill, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // Fetch specific questions
        // Show loading
        showDialog(
           context: context,
           barrierDismissible: false,
           builder: (c) => Center(child: CircularProgressIndicator()),
        );

        try {
           final qData = await SupabaseService().getQuestionsForSkill(skill.id);
           
           if (!context.mounted) return;
           Navigator.pop(context); // Hide loading

           if (qData.isEmpty) {
             // Fallback to sample data if DB has no questions for this skill yet
              if (Quiz.sampleData.isNotEmpty) {
                 context.read<QuizProvider>().loadQuestions(Quiz.sampleData);
                 context.read<QuizProvider>().startQuiz(QuizMode.practice);
                 Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen()));
                 return;
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No questions found.")));
              return;
           }

           final questions = qData.map((e) => Question.fromJson(e)).toList();
           context.read<QuizProvider>().loadQuestions(questions);
           context.read<QuizProvider>().startQuiz(QuizMode.practice);
           Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen()));

        } catch (e) {
            if (context.mounted) Navigator.pop(context);
            // Fallback for demo purposes if DB fails or is empty
            context.read<QuizProvider>().loadQuestions(Quiz.sampleData);
            context.read<QuizProvider>().startQuiz(QuizMode.practice);
            Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen()));
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: skill.isLocked ? Colors.grey[200] : color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                skill.isLocked ? Icons.lock_outline : Icons.play_arrow_rounded,
                color: skill.isLocked ? Colors.grey : color,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: skill.isLocked ? Colors.grey : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
