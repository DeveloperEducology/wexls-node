import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../home/domain/models.dart';
import '../../auth/presentation/login_screen.dart';
import '../../home/presentation/home_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  User? _user;
  bool _isLoading = false;
  
  Map<String, dynamic>? _profile;
  // Currently selected grade in dropdown (or from profile)
  

  @override
  void initState() {
    super.initState();
    _init();
    
    // Listen to auth changes
    SupabaseService().authStateChanges.listen((data) {
       if (mounted) {
         setState(() {
           _user = data.session?.user;
         });
         if (_user != null) _loadProfile();
       }
    });
  }

  void _init() async {
    final user = SupabaseService().currentUser;
    if (mounted) setState(() => _user = user);
    if (user != null) {
       await _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      // Load Profile
      final p = await SupabaseService().fetchUserProfile();
      
      // Load Grades for Dropdown
      
      if (mounted) {
        setState(() {
          _profile = p;
          
          // Validate if the user's current grade still exists in the DB (since we rebuilt schema)
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading profile data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  

  Future<void> _logout() async {
    await SupabaseService().signOut();
    if (mounted) {
      setState(() {
        _user = null;
        _profile = null;
        
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: _user == null 
          ? _buildAnonView()
          : _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildUserView(),
    );
  }

  Widget _buildAnonView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_circle, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("You are not signed in.", style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
               Navigator.of(context).push(
                 MaterialPageRoute(builder: (_) => const LoginScreen())
               );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text("Sign In / Register", style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserView() {
    final email = _user?.email ?? "";
    final metadata = _user?.userMetadata ?? {};
    final name = metadata['full_name'] ?? "User";
    final phone = metadata['phone_number'] ?? "";

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Center(
             child: CircleAvatar(
               radius: 50,
               backgroundColor: AppColors.primaryGreen,
               child: Text(name.isNotEmpty ? name[0].toUpperCase() : "U", style: const TextStyle(fontSize: 40, color: Colors.white)),
             ),
           ),
           const SizedBox(height: 24),
           _buildInfoRow("Name", name),
           const Divider(),
           _buildInfoRow("Email", email),
           const Divider(),
           if (phone.isNotEmpty) ...[
             _buildInfoRow("Phone", phone),
             const Divider(),
           ],
           
           
           
           const Spacer(),
           
           SizedBox(
             width: double.infinity,
             child: OutlinedButton.icon(
               onPressed: _logout,
               icon: const Icon(Icons.logout, color: Colors.red),
               label: const Text("Sign Out", style: TextStyle(color: Colors.red)),
               style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
             ),
           )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
