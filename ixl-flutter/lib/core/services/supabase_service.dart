import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/practice/domain/models.dart';
import '../../features/home/domain/models.dart';
import '../../features/skills/domain/models.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  // --- QUESTIONS ---
  Future<List<QuestionModel>> fetchQuestions({String? microSkillId, int limit = 20, int offset = 0}) async {
    try {
      var query = client.from('questions').select();
      
      if (microSkillId != null) {
        query = query.eq('micro_skill_id', microSkillId);
      }
      
      final response = await query.order('created_at', ascending: false).range(offset, offset + limit - 1);
      final data = response as List<dynamic>;
      return data.map((json) => QuestionModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching questions: $e');
      return [];
    }
  }

  Future<QuestionModel?> fetchQuestionById(String id) async {
    try {
      final response = await client.from('questions').select().eq('id', id).maybeSingle();
      if (response == null) return null;
      return QuestionModel.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching question $id: $e");
      return null;
    }
  }

  // --- HOME (Grades & Subjects) ---
  Future<List<GradeModel>> fetchGrades() async {
    final response = await client
        .from('grades')
        .select()
        .order('sort_order', ascending: true);
    
    return (response as List).map((e) => GradeModel.fromJson(e)).toList();
  }

  Future<List<SubjectModel>> fetchSubjects() async {
    final response = await client
        .from('subjects')
        .select();
    
    return (response as List).map((e) => SubjectModel.fromJson(e)).toList();
  }

  Future<List<SubjectModel>> fetchSubjectsForGrade(String gradeId) async {
    try {
      // V2 Schema: Subjects are directly linked to Grades
      final response = await client
          .from('subjects')
          .select()
          .eq('grade_id', gradeId)
          .order('name', ascending: true);
          
      return (response as List).map((e) => SubjectModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error fetching subjects for grade: $e");
      return [];
    }
  }

  // --- SKILLS ---
  Future<List<UnitModel>> fetchUnitsWithSkills(String gradeId, String subjectId) async {
    try {
      // Fetch Units first (or use join if RLS/relation setup permits deep select)
      // Supabase supports deep select:
      // select('*, micro_skills(*)')
      
      final response = await client
          .from('units')
          .select('*, micro_skills(*)')
          .eq('subject_id', subjectId)
          .order('sort_order', ascending: true);
          
      // Note: We need to handle sorting of micro_skills manually or via modifier if allowed in nested
      // Typically nested sort is tricky in one go, but let's try.
      // If order of skills is random, we sort in Dart.
      
      final List<UnitModel> units = (response as List).map((e) {
         // Sort skills in dart
         final unit = UnitModel.fromJson(e);
         unit.skills.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
         return unit;
      }).toList();
      
      return units;
    } catch (e) {
       debugPrint('Error fetching units/skills: $e');
       return [];
    }
  }

  // --- AUTH ---
  User? get currentUser => client.auth.currentUser;
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password, {String? fullName, String? phoneNumber}) async {
    return await client.auth.signUp(
      email: email, 
      password: password, 
      data: {
        'full_name': fullName,
        'phone_number': phoneNumber,
      }
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // --- PROGRESS ---
  Future<void> savePracticeSession({
    required String skillId,
    required int score,
    required int questionsAnswered,
    required int correctCount,
    required int elapsedSeconds,
    int? targetComplexity,
    String? skillName,
  }) async {
     final user = currentUser;
     if (user == null) return;
     
     await client.from('practice_sessions').insert({
       'user_id': user.id,
       'skill_id': skillId,
       'skill_name': skillName,
       'smart_score': score,
       'questions_answered': questionsAnswered,
       'correct_count': correctCount,
       'elapsed_seconds': elapsedSeconds,
       'target_complexity': targetComplexity ?? 10,
     });
  }

  Future<void> reportQuestion(String questionId, String feedback) async {
    final user = currentUser;
    await client.from('question_feedback').insert({
      'question_id': questionId,
      'user_id': user?.id,
      'feedback': feedback,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> fetchLastSession(String skillId) async {
      final user = currentUser;
      if (user == null) return null;

      try {
        final data = await client
            .from('practice_sessions')
            .select()
            .eq('user_id', user.id)
            .eq('skill_id', skillId)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
        return data; // Returns Map or null
      } catch (e) {
        debugPrint("Error fetching last session: $e");
        return null;
      }
  }

  Future<List<Map<String, dynamic>>> fetchUserAnalytics() async {
      final user = currentUser;
      if (user == null) return [];

      try {
        // Fetch all sessions (Limit 1000 for safety)
        final data = await client
            .from('practice_sessions')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false)
            .limit(1000);
            
        return List<Map<String, dynamic>>.from(data);
      } catch (e) {
        debugPrint("Error fetching analytics: $e");
        return [];
      }
  }

  Future<Map<String, dynamic>?> fetchLatestActivity() async {
      final user = currentUser;
      if (user == null) return null;
      try {
        final data = await client
            .from('practice_sessions')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
        
        // If skill_name is missing, try to fetch it
        if (data != null && (data['skill_name'] == null || data['skill_name'].isEmpty)) {
             final skillId = data['skill_id'];
             final skillDetails = await fetchSkillDetails(skillId);
             if (skillDetails != null) {
                final newName = skillDetails['title'] ?? skillDetails['name'];
                data['skill_name'] = newName;
                // Optionally update DB? Maybe overkill for now.
             }
        }
        return data;
      } catch (e) {
        return null;
      }
  }

  Future<Map<String, int>> fetchDailyStats() async {
    final user = currentUser;
    if (user == null) return {'today': 0, 'total': 0};
    
    try {
       // Total
       final totalRes = await client.from('practice_sessions')
          .select('questions_answered')
          .eq('user_id', user.id);
          
       int total = 0;
       for (var row in totalRes) {
          total += (row['questions_answered'] as int?) ?? 0;
       }

       // Today
       final todayStr = DateTime.now().toIso8601String().split('T')[0];
       final todayRes = await client.from('practice_sessions')
          .select('questions_answered')
          .eq('user_id', user.id)
          .gte('created_at', '$todayStr 00:00:00');
          
       int today = 0;
       for (var row in todayRes) {
          today += (row['questions_answered'] as int?) ?? 0;
       }
       
       return {'today': today, 'total': total};
    } catch (e) {
       return {'today': 0, 'total': 0};
    }
  }

  Future<Map<String, dynamic>?> fetchSkillDetails(String skillId) async {
    try {
      final data = await client
        .from('micro_skills')
        .select('title, name') // title or name depending on schema
        .eq('id', skillId)
        .maybeSingle();
      return data;
    } catch(e) {
      return null;
    }
  }

  // --- PROFILE ---
  Future<Map<String, dynamic>?> fetchUserProfile() async {
     final user = currentUser;
     if (user == null) return null;
     
     try {
       final data = await client
         .from('profiles')
         .select()
         .eq('id', user.id)
         .maybeSingle();
       return data;
     } catch (e) {
       debugPrint("Error fetching profile: $e");
       return null;
     }
  }

  Future<void> updateUserGrade(String gradeId) async {
    final user = currentUser;
    if (user == null) return;
    
    await client
      .from('profiles')
      .update({'grade_id': gradeId, 'updated_at': DateTime.now().toIso8601String()})
      .eq('id', user.id);
  }
}
