import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'category_selection_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final profile = await SupabaseService().getUserProfile();
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Default profile data if db fetch returns null
    final String name = _profile?['full_name'] ?? 'Learner';
    final String email = Supabase.instance.client.auth.currentUser?.email ?? 'learner@example.com';
    final String phone = _profile?['phone'] ?? '+91 98765 43210';
    final String userClass = _profile?['user_class'] ?? 'Class 6';

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20),
            // Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Color(0xFF0052D4), width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF0052D4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    email,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32),
            
            // Statistics Card
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem("12", "Tests Taken"),
                  Container(height: 40, width: 1, color: Colors.grey[200]),
                  _buildStatItem("85%", "Avg Score"),
                  Container(height: 40, width: 1, color: Colors.grey[200]),
                  _buildStatItem("4", "Rank"),
                ],
              ),
            ),
            
            SizedBox(height: 32),

            // Profile Options
            _buildOptionTile(
              icon: Icons.person_outline, 
              title: "Personal Information", 
              subtitle: "Edit your details",
              onTap: () {},
            ),
            _buildOptionTile(
              icon: Icons.school_outlined, 
              title: "Academic Details", 
              subtitle: "Class: $userClass",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategorySelectionScreen()),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.notifications_none, 
              title: "Notifications", 
              subtitle: "Manage your alerts",
              onTap: () {},
            ),
            _buildOptionTile(
              icon: Icons.security, 
              title: "Password & Security", 
              subtitle: "Update password",
              onTap: () {},
            ),            
            SizedBox(height: 20),
            
            // Logout Button
            TextButton(
              onPressed: () async {
                await SupabaseService().signOut();
                // Navigate to login/signup. 
                // Since I might not have a full auth flow set up in this context, 
                // I will just show a snackbar or restart depending on app structure.
                // Assuming we want to restart app:
                // Navigator.pushReplacementNamed(context, '/'); // If routes defined
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Logout", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0052D4),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFFF5F7FA),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF0052D4)),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
