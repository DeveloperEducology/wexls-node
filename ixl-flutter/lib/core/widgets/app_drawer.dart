import 'package:flutter/material.dart';
import '../../features/home/presentation/class_selection_screen.dart';
import '../services/supabase_service.dart';
import '../constants/colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService().currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'User';
    final userEmail = user?.email ?? '';

    return Drawer(
      child: Column(
        children: [
          // Header with User Profile
          UserAccountsDrawerHeader(
            accountName: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(userEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primaryGreen, size: 40),
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
            ),
          ),
          
          // Menu Items
          ListTile(
            leading: const Icon(Icons.school, color: AppColors.primaryGreen),
            title: const Text('Change Class'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClassSelectionScreen()),
              );
            },
          ),
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.grey),
            title: const Text('Sign Out'),
            onTap: () async {
              await SupabaseService().signOut();
              if (context.mounted) {
                 Navigator.pop(context); // close drawer
                 // Usually auth logic handles redirect, or we can push login
              }
            },
          ),
        ],
      ),
    );
  }
}
