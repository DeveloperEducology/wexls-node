import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'auth_screen.dart';
import 'category_selection_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Artificial delay for splash effect
    await Future.delayed(Duration(seconds: 1));

    final service = SupabaseService();
    final user = service.currentUser;

    if (!mounted) return;

    if (user == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AuthScreen()));
    } else {
      // Check if user has setup profile
      bool hasProfile = await service.hasSelectedCategories();
      if (!mounted) return;
      
      if (hasProfile) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
         Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => CategorySelectionScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0052D4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_rounded, size: 80, color: Colors.white),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
