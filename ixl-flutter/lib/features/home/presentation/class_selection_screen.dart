import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/supabase_service.dart';
import 'home_providers.dart';

class ClassSelectionScreen extends ConsumerWidget {
  final bool isFirstTime;

  const ClassSelectionScreen({super.key, this.isFirstTime = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradesAsync = ref.watch(gradesProvider);
    final userProfileAsync = ref.watch(userGradeProvider);
    final currentGradeId = userProfileAsync.asData?.value?['grade_id'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Class", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryGreen,
        automaticallyImplyLeading: !isFirstTime, 
      ),
      body: gradesAsync.when(
        data: (grades) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: grades.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final grade = grades[index];
              final isSelected = grade.id == currentGradeId;
              
              return InkWell(
                onTap: () async {
                  // Update Grade
                  await SupabaseService().updateUserGrade(grade.id);
                  
                  // Refresh Data
                  ref.refresh(userGradeProvider);
                  
                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text("Class set to ${grade.name}")),
                     );
                     
                     if (isFirstTime) {
                       // If we are forcing this view, we might need to reload or just let the parent rebuild
                       // Typically we just pop if it was pushed
                     } else {
                       Navigator.of(context).pop();
                     }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: isSelected ? AppColors.primaryGreen : Colors.grey.shade200,
                        child: Icon(
                          Icons.school, 
                          color: isSelected ? Colors.white : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        grade.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.primaryGreen : Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppColors.primaryGreen),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
