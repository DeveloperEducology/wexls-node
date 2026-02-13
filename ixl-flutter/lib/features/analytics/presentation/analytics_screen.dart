import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/supabase_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _sessions = [];
  
  // Processed Data
  Map<String, Map<String, dynamic>> _latestSkillStatus = {};
  int _totalQuestionsLifetime = 0;
  int _totalTimeLifetime = 0; // seconds

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final data = await SupabaseService().fetchUserAnalytics();
    debugPrint("Analytics Data Size: ${data.length}");
    if (data.isEmpty) {
       // Check if current user is null?
       final user = SupabaseService().currentUser;
       debugPrint("Current User: ${user?.id}");
    }
    
    // Process Data
    final Map<String, Map<String, dynamic>> skills = {};
    int totalQ = 0;
    int totalTime = 0;
    
    for (var session in data) {
      final skillId = session['skill_id'] as String;
      final questions = (session['questions_answered'] as int?) ?? 0;
      final time = (session['elapsed_seconds'] as int?) ?? 0;
      
      // Lifetime aggregations
      totalQ += questions;
      totalTime += time;
      
      // Latest Status (Data is ordered by created_at DESC, so first time we see a skill is the latest)
      if (!skills.containsKey(skillId)) {
        skills[skillId] = session;
      }
    }



    // Resolve missing skill names (Backfill)
    final missingNameIds = skills.values
        .where((s) => (s['skill_name'] as String?) == null || (s['skill_name'] as String).isEmpty)
        .map((s) => s['skill_id'] as String)
        .toSet();

    if (missingNameIds.isNotEmpty) {
       for (final id in missingNameIds) {
          try {
             final details = await SupabaseService().fetchSkillDetails(id);
             if (details != null) {
                final updatedSession = Map<String, dynamic>.from(skills[id]!);
                updatedSession['skill_name'] = details['title'] ?? details['name'];
                skills[id] = updatedSession;
             }
          } catch (e) {
             debugPrint("Failed to resolve name for $id");
          }
       }
    }

    if (mounted) {
      setState(() {
        _sessions = data;
        // Filter out Unknown Skills
        _latestSkillStatus = Map.fromEntries(skills.entries.where((e) {
           final name = e.value['skill_name'] as String?;
           return name != null && name.isNotEmpty && name != 'Unknown Skill';
        }));
        _totalQuestionsLifetime = totalQ;
        _totalTimeLifetime = totalTime;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_sessions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My Progress", style: TextStyle(color: Colors.white)),
          backgroundColor: AppColors.primaryGreen,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.analytics_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("No practice history yet.", style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Home tab? (Hack: relying on parent scaffold state or just telling user)
                  // For now simple text
                }, 
                child: const Text("Start Practicing!")
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Progress", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryGreen,
      ),
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Card
            _buildSummaryCard(),
            const SizedBox(height: 24),
            
            // Skill List 
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Recent Skills", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 16),
            
            ..._latestSkillStatus.values.map((session) => _buildSkillCard(session)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final hours = _totalTimeLifetime ~/ 3600;
    final minutes = (_totalTimeLifetime % 3600) ~/ 60;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.primaryGreen.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.primaryGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(Icons.question_answer, "$_totalQuestionsLifetime", "Questions"),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildSummaryItem(Icons.timer, "${hours}h ${minutes}m", "Time Spent"),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildSummaryItem(Icons.emoji_events, "${_latestSkillStatus.length}", "Skills"),
        ],
      ),
    );
  }
  
  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildSkillCard(Map<String, dynamic> session) {
    final score = session['smart_score'] ?? 0;
    final skillName = session['skill_name'] ?? 'Unknown Skill';
    final complexity = session['target_complexity'] ?? 0;
    final date = DateTime.tryParse(session['created_at'] ?? '');
    final dateStr = date != null ? DateFormat('MMM d').format(date) : '';

    Color scoreColor = AppColors.scoreRed;
    String badge = '';
    
    if (score >= 100) {
      scoreColor = Colors.amber; 
      badge = '🏆';
    } else if (score >= 90) {
      scoreColor = Colors.amber;
      badge = '🥇';
    } else if (score >= 80) {
      scoreColor = Colors.blueGrey; // Silverish
      badge = '🥈';
    } else if (score >= 50) {
      scoreColor = AppColors.scoreOrange;
    } else if (score >= 70) {
        // Overlap logic fix
    }
    
    // Better logic
    if (score >= 80) scoreColor = AppColors.scoreGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
           // Score Circle
           Container(
             width: 60,
             height: 60,
             decoration: BoxDecoration(
               color: scoreColor.withOpacity(0.1),
               shape: BoxShape.circle,
               border: Border.all(color: scoreColor, width: 2),
             ),
             child: Center(
               child: Text(
                 "$score", 
                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: scoreColor)
               ),
             ),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(skillName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 4),
                 Row(
                   children: [
                     Icon(Icons.trending_up, size: 16, color: Colors.grey.shade600),
                     const SizedBox(width: 4),
                     Text("Complexity: $complexity", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                     if (badge.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(badge, style: const TextStyle(fontSize: 16)),
                     ]
                   ],
                 ),
               ],
             ),
           ),
           Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
                Text(dateStr, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                // Maybe a "Practice" button?
             ],
           )
        ],
      ),
    );
  }
}
