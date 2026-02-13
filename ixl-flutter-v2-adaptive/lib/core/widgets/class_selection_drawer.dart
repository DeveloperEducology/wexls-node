
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/presentation/home_providers.dart';
import '../services/supabase_service.dart';
import '../constants/colors.dart';

class ClassSelectionDrawer extends ConsumerWidget {
  const ClassSelectionDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradesAsync = ref.watch(gradesProvider);
    final userProfileAsync = ref.watch(userGradeProvider);
    
    // Get current grade ID safely
    final currentGradeId = userProfileAsync.asData?.value?['grade_id'];

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            color: AppColors.primaryGreen,
            child: const Text(
              "Select Class",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: gradesAsync.when(
              data: (grades) {
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: grades.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final grade = grades[index];
                    final isSelected = grade.id == currentGradeId;
                    
                    return ListTile(
                      title: Text(
                        grade.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primaryGreen : Colors.black87,
                        ),
                      ),
                      trailing: isSelected 
                          ? const Icon(Icons.check_circle, color: AppColors.primaryGreen)
                          : null,
                      onTap: () async {
                        // Update Grade
                        await SupabaseService().updateUserGrade(grade.id);
                        
                        // Refresh Data
                        ref.refresh(userGradeProvider);
                        
                        // Close Drawer
                        if (context.mounted) Navigator.pop(context);
                        
                        // Show Feedback
                        if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text("Switched to ${grade.name}")),
                           );
                        }
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }
}
