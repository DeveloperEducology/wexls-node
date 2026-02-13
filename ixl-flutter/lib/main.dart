import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_router.dart';
import 'core/constants/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://gfbyqabgrxfzwdbailyy.supabase.co',
      anonKey: 'sb_publishable_W9h0sQcP7rbBqb-jW4of9g_WUJWRzhq',
    );
  } catch (e) {
    debugPrint("Supabase Initialisation Failed (Expected if keys are missing): $e");
  }

  runApp(const ProviderScope(child: IXLApp()));
}

class IXLApp extends StatelessWidget {
  const IXLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'IXL Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          surface: AppColors.surface,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: AppColors.background,
      ),
      routerConfig: router,
    );
  }
}
