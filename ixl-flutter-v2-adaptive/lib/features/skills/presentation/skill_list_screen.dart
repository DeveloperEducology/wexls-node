import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/app_header.dart';
import '../domain/models.dart';

// --- PROVIDER ---
final unitsProvider = FutureProvider.family<List<UnitModel>, ({String gradeId, String subjectId})>((ref, args) async {
  return SupabaseService().fetchUnitsWithSkills(args.gradeId, args.subjectId);
});

class SkillListScreen extends ConsumerWidget {
  final String gradeId;
  final String subjectId;
  final String gradeName;
  final String subjectName;

  const SkillListScreen({
    super.key,
    required this.gradeId,
    required this.subjectId,
    required this.gradeName,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch units (and their skills) from DB
    final unitsAsync = ref.watch(unitsProvider((gradeId: gradeId, subjectId: subjectId)));

    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb & Selectors (Visual Only)
              _buildControlBar(gradeName, subjectName),
              const Gap(24),
              Text(
                '$gradeName $subjectName',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Gap(8),
              Text(
                'Here is a list of all of the $subjectName skills students learn in $gradeName.',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const Gap(32),
              
              unitsAsync.when(
                data: (units) {
                  if (units.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("No skills found for this Grade/Subject. Please check DB seed."),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: units.length,
                    itemBuilder: (context, index) {
                      final unit = units[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  unit.code,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: Text(
                                    unit.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...unit.skills.map<Widget>((skill) {
                            return InkWell(
                              onTap: () {
                                // Navigate to practice with the actual Micro Skill ID
                                context.push('/practice/${skill.id}');
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6.0, horizontal: 0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      child: Text(
                                        skill.code,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    const Gap(12),
                                    Expanded(
                                      child: Text(
                                        skill.name,
                                        style: const TextStyle(
                                          color: AppColors.darkGreen,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.lightGreen,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }), // .toList() is not needed for spread in recent dart but keeping it implicitly via map
                          const Gap(24),
                        ],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlBar(String grade, String subject) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$grade > $subject',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        Container(width: 1, height: 20, color: Colors.grey),
        _buildDropdown('Subject'),
        _buildDropdown('Grade'),
      ],
    );
  }

  Widget _buildDropdown(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(hint, style: const TextStyle(fontSize: 14)),
          const Icon(Icons.arrow_drop_down, size: 20),
        ],
      ),
    );
  }
}
