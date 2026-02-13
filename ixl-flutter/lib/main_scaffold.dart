import 'package:flutter/material.dart';
import 'core/constants/colors.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/analytics/presentation/analytics_screen.dart';
import 'features/analytics/presentation/analytics_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    SupabaseService().authStateChanges.listen((data) {
       if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = SupabaseService().currentUser?.id;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
           HomeScreen(key: ValueKey('home_$userId')),
           AnalyticsScreen(key: ValueKey('analytics_$userId')),
           ProfileScreen(key: ValueKey('profile_$userId')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
