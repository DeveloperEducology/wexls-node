
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/models.dart';

final subjectsForGradeProvider = FutureProvider.family<List<SubjectModel>, String>((ref, gradeId) async {
  return SupabaseService().fetchSubjectsForGrade(gradeId);
});

final userGradeProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // We can also subscribe to realtime changes here if we wanted, 
  // but for now simple fetch is fine.
  return SupabaseService().fetchUserProfile();
});

final gradesProvider = FutureProvider<List<GradeModel>>((ref) async {
  return SupabaseService().fetchGrades();
});
