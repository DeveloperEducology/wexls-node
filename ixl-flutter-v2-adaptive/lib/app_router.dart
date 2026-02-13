import 'package:go_router/go_router.dart';

import 'main_scaffold.dart';
import 'features/skills/presentation/skill_list_screen.dart';
import 'features/practice/presentation/practice_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScaffold(),
    ),
    GoRoute(
      path: '/skills/:gradeId/:subjectId',
      builder: (context, state) {
        final gradeId = state.pathParameters['gradeId']!;
        final subjectId = state.pathParameters['subjectId']!;
        
        // Optional query params for display
        final gradeName = state.uri.queryParameters['gradeName'] ?? 'Grade';
        final subjectName = state.uri.queryParameters['subjectName'] ?? 'Subject';
        
        return SkillListScreen(
            gradeId: gradeId, 
            subjectId: subjectId,
            gradeName: gradeName,
            subjectName: subjectName
        );
      },
    ),
    GoRoute(
      path: '/practice/:skillId',
      builder: (context, state) {
        final skillId = state.pathParameters['skillId']!;
        return PracticeScreen(skillId: skillId);
      },
    ),
  ],
);
