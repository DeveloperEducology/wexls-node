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
  }) async {
     final user = currentUser;
     if (user == null) return;
     
     await client.from('practice_sessions').insert({
       'user_id': user.id,
       'skill_id': skillId,
       'smart_score': score,
       'questions_answered': questionsAnswered,
       'correct_count': correctCount,
       'elapsed_seconds': elapsedSeconds,
     });
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
