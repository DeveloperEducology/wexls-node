import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/class_selection_drawer.dart';
import '../domain/models.dart';
import 'widgets/grade_card.dart';
import '../../auth/presentation/login_screen.dart';
import 'home_providers.dart';

// Providers moved to home_providers.dart

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // If not logged in or no grade selected, we might show a selector?
  // Or force them to Profile.
  // Requirement: "user login see the grades, select one grade and then home page view subjects"
  
  @override
  Widget build(BuildContext context) {
    final user = SupabaseService().currentUser;
    if (user == null) {
       return _buildGuestView();
    }
    
    final profileAsync = ref.watch(userGradeProvider);
    
    return Scaffold(
      appBar: const AppHeader(),
      endDrawer: ClassSelectionDrawer(),
      body: profileAsync.when(
        data: (profile) {
           final gradeId = profile?['grade_id'];
           if (gradeId == null) {
              return _buildSelectGradeView();
           }
           // Fetch Grade info to display name? (Optional)
           return _buildSubjectsView(gradeId);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }

  Widget _buildGuestView() {
    return Scaffold(
      appBar: const AppHeader(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             const Icon(Icons.school, size: 80, color: AppColors.primaryGreen),
             const SizedBox(height: 16),
             const Text("Welcome to IXL Learning", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
             const SizedBox(height: 8),
             const Text("Please sign in to select your class.", style: TextStyle(color: Colors.grey)),
             const SizedBox(height: 24),
             ElevatedButton(
               onPressed: () {
                 Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())).then((_) {
                    setState(() {}); // Refresh on return
                    ref.refresh(userGradeProvider);
                 });
               },
               style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
               child: const Text("Sign In", style: TextStyle(color: Colors.white)),
             )
          ],
        ),
      ),
    );
  }

  Widget _buildSelectGradeView() {
    final gradesAsync = ref.watch(gradesProvider);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
           const Text("Select your Class", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
           const SizedBox(height: 16),
           Expanded(
             child: gradesAsync.when(
               data: (grades) => ListView.separated(
                 itemCount: grades.length,
                 separatorBuilder: (c, i) => const SizedBox(height: 12),
                 itemBuilder: (context, index) {
                   final g = grades[index];
                   return InkWell(
                     onTap: () async {
                        // Update profile
                        await SupabaseService().updateUserGrade(g.id);
                        ref.refresh(userGradeProvider);
                     },
                     child: Container(
                       padding: const EdgeInsets.all(20),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         border: Border.all(color: AppColors.primaryGreen),
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: Text(g.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                     ),
                   );
                 },
               ),
               loading: () => const Center(child: CircularProgressIndicator()),
               error: (e, s) => Text("Error: $e"),
             ),
           )
        ],
      ),
    );
  }

  Widget _buildSubjectsView(String gradeId) {
    // Show Subjects Grid (Filtered by Grade)
    final subjectsAsync = ref.watch(subjectsForGradeProvider(gradeId));
    
    return subjectsAsync.when(
      data: (subjects) {
          if (subjects.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.class_outlined, size: 60, color: Colors.grey),
                   const SizedBox(height: 16),
                   const Text("No subjects available for this grade yet.", style: TextStyle(color: Colors.grey, fontSize: 16)),
                   TextButton(
                     onPressed: () {
                        // Clear grade to pick another one? 
                        // For now just navigate to Profile
                        final tabs = DefaultTabController.of(context);
                        if (tabs != null) {
                           tabs.animateTo(2); // Attempt to switch to Profile tab if possible, otherwise we need a better way.
                        } else {
                           // Since we are in MainScaffold, we can't easily switch tabs from here without a provider or global key.
                           // Let's just show a snackbar or simple message
                        }
                     }, 
                     child: const Text("Check back later or change grade in Profile.")
                   )
                 ],
               )
             );
          }
          
          return Column(
            children: [
               Container(
                 padding: const EdgeInsets.all(16),
                 color: Colors.grey.shade100,
                 width: double.infinity,
                 child: const Text("My Subjects", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
               ),
               Expanded(
                 child: GridView.builder(
                   padding: const EdgeInsets.all(16),
                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                     crossAxisCount: 2,
                     childAspectRatio: 1.1,
                     crossAxisSpacing: 16,
                     mainAxisSpacing: 16,
                   ),
                   itemCount: subjects.length,
                   itemBuilder: (context, index) {
                      final s = subjects[index];
                      return GestureDetector(
                        onTap: () {
                           context.push('/skills/$gradeId/${s.id}?subjectName=${s.name}');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                            ]
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icon placeholder
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: s.name == "Math" ? Colors.orange.shade100 : Colors.blue.shade100,
                                child: Icon(
                                  s.name == "Math" ? Icons.calculate : Icons.book, 
                                  color: s.name == "Math" ? Colors.orange : Colors.blue,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(s.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                   },
                 ),
               ),
            ],
          );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e,s) => Center(child: Text("Error: $e")),
    );
  }
}
