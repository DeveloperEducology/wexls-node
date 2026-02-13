import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;

  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  // Auth Methods
  Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  User? get currentUser => client.auth.currentUser;

  // Data Methods
  Future<List<Map<String, dynamic>>> getExamCategories() async {
    return await client.from('exam_categories').select();
  }

  Future<void> updateUserCategories(List<String> categoryIds) async {
    final user = currentUser;
    if (user == null) return;

    await client.from('profiles').upsert({
      'id': user.id,
      'exam_categories': categoryIds,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> hasSelectedCategories() async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final response = await client.from('profiles').select('exam_categories').eq('id', user.id).maybeSingle();
      if (response == null) return false;
      final categories = response['exam_categories'];
      return categories != null && (categories as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    return await client.from('profiles').select().eq('id', user.id).maybeSingle();
  }

  Future<List<Map<String, dynamic>>> getTestSeries({String? targetClass, List<String>? categories, String? type}) async {
    var query = client.from('test_series').select();
    
    // Type filter (mock or previous)
    if (type != null) {
      query = query.eq('type', type);
    }

    // If targetClass is provided, filter by it
    if (targetClass != null && targetClass.isNotEmpty) {
       query = query.eq('target_class', targetClass);
    } 
    // If we want to filter by categories (if active_class is null)
    else if (categories != null && categories.isNotEmpty) {
       query = query.inFilter('category', categories);
    }

    return await query;
  }
  
  Future<List<Map<String, dynamic>>> getQuestionsForTest(String testId) async {
    return await client.from('questions').select().eq('test_id', testId);
  }

  // Practice Mode Methods
  
  Future<List<Map<String, dynamic>>> getUnitsForSubject(String subjectName) async {
    // 1. Get Subject ID
    final subjectRes = await client
        .from('subjects')
        .select('id')
        .eq('name', subjectName)
        .maybeSingle();
        
    if (subjectRes == null) return [];

    final subjectId = subjectRes['id'];

    // 2. Get Units with Micro Skills
    // Sort units by order_index
    final response = await client
        .from('units')
        .select('*, micro_skills(*)')
        .eq('subject_id', subjectId)
        .order('order_index', ascending: true);
        
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getSubjects() async {
    return await client.from('subjects').select().order('name', ascending: true);
  }

  Future<List<Map<String, dynamic>>> getQuestionsForSkill(String skillId) async {
    // Randomize? For now just fetch all.
    return await client.from('questions').select().eq('micro_skill_id', skillId);
  }

  // Activity / Results
  Future<void> saveActivity({
    required String title,
    required String type,
    required int score,
    required int totalScore,
    required bool passed,
  }) async {
    final user = currentUser;
    if (user == null) return;

    await client.from('student_activities').insert({
      'user_id': user.id,
      'test_title': title,
      'test_type': type,
      'score': score,
      'total_score': totalScore,
      'passed': passed,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    final user = currentUser;
    if (user == null) return [];

    return await client
        .from('student_activities')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(5);
  }
}
