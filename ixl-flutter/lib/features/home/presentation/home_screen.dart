import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_drawer.dart';
import '../domain/models.dart';
import 'widgets/grade_card.dart';
import 'class_selection_screen.dart'; // Import
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
      endDrawer: const AppDrawer(), // Updated
      body: profileAsync.when(
        data: (profile) {
           final gradeId = profile?['grade_id'];
           if (gradeId == null) {
              return const ClassSelectionScreen(isFirstTime: true);
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

  // _buildSelectGradeView is now replaced by ClassSelectionScreen

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
          
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              // Calculate grid count: min 2, max 6, approx 250px per item
              final gridCount = (constraints.maxWidth / 250).floor().clamp(2, 6);

              return Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    children: [
                       isWide 
                         ? IntrinsicHeight(
                             child: Row(
                               crossAxisAlignment: CrossAxisAlignment.stretch,
                               children: [
                                 Expanded(flex: 3, child: _buildHeader()),
                                 Expanded(flex: 2, child: Padding(
                                   padding: const EdgeInsets.only(top: 4.0), // Align visually with header padding
                                   child: _buildResumeCard(),
                                 )),
                               ],
                             ),
                           )
                         : Column(
                             children: [
                               _buildHeader(),
                               _buildResumeCard(),
                             ],
                           ),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                         width: double.infinity,
                         child: const Text("My Subjects", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                       ),
                       Expanded(
                         child: GridView.builder(
                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                             crossAxisCount: gridCount,
                             childAspectRatio: 1.1,
                             crossAxisSpacing: 20,
                             mainAxisSpacing: 20,
                           ),
                           itemCount: subjects.length,
                           itemBuilder: (context, index) {
                              final s = subjects[index];
                              return GestureDetector(
                                onTap: () {
                                   context.push('/skills/$gradeId/${s.id}?subjectName=${s.name}');
                                },
                                child: MouseRegion( // Add hover effect on web if desired, for now just container
                                  cursor: SystemMouseCursors.click,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                                      ],
                                      border: Border.all(color: Colors.grey.shade100),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Icon placeholder
                                        CircleAvatar(
                                          radius: 36,
                                          backgroundColor: s.name == "Math" ? Colors.orange.shade50 : Colors.blue.shade50,
                                          child: Icon(
                                            s.name == "Math" ? Icons.calculate : Icons.book, 
                                            color: s.name == "Math" ? Colors.orange : Colors.blue,
                                            size: 36,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(s.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                           },
                         ),
                       ),
                    ],
                  ),
                ),
              );
            }
          );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e,s) => Center(child: Text("Error: $e")),
    );
  }

  Widget _buildResumeCard() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: SupabaseService().fetchLatestActivity(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) return const SizedBox.shrink();
        
        final session = snapshot.data!;
        final skillName = session['skill_name'] ?? 'Unknown Skill';
        final skillId = session['skill_id'];
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primaryGreen, AppColors.darkGreen]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
               BoxShadow(color: AppColors.primaryGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
            ]
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.play_arrow, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Jump back in!", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(skillName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                   context.push('/practice/$skillId?skillName=${Uri.encodeComponent(skillName)}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
                child: const Text("Resume"),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting = "Good Morning";
    if (hour >= 12 && hour < 17) greeting = "Good Afternoon";
    else if (hour >= 17) greeting = "Good Evening";

    return FutureBuilder<Map<String, int>>(
      future: SupabaseService().fetchDailyStats(),
      builder: (context, snapshot) {
         final stats = snapshot.data ?? {'today': 0, 'total': 0};
         final today = stats['today']!;
         
         return Container(
           padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(greeting, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                   const Text("Ready to learn?", style: TextStyle(color: Colors.grey)),
                 ],
               ),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(16),
                   boxShadow: [
                     BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                   ]
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                     Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         const Icon(Icons.bolt, color: Colors.orange, size: 20),
                         Text("$today/20 Daily Goal", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 12)),
                       ],
                     ),
                     const SizedBox(height: 6),
                     SizedBox(
                       width: 100,
                       height: 6,
                       child: LinearProgressIndicator(
                         value: (today / 20).clamp(0.0, 1.0),
                         backgroundColor: Colors.grey.shade200,
                         color: Colors.orange,
                         borderRadius: BorderRadius.circular(3),
                       ),
                     ),
                   ],
                 ),
               )
             ],
           ),
         );
      }
    );
  }
}
