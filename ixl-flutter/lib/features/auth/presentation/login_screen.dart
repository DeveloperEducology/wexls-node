import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/supabase_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await SupabaseService().signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true); // Return true on success
    } catch (e) {
      if (mounted) {
        setState(() {
           _error = e.toString().contains("Invalid login") 
             ? "Invalid email or password." 
             : "Login failed. Please try again.";
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Scaffold(
            body: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryGreen, AppColors.darkGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         const Icon(Icons.school, size: 120, color: Colors.white),
                         const SizedBox(height: 32),
                         const Text(
                           "IXL Learning",
                           style: TextStyle(
                             color: Colors.white,
                             fontSize: 40,
                             fontWeight: FontWeight.bold,
                             letterSpacing: 1.2
                           )
                         ),
                         const SizedBox(height: 16),
                         const Text(
                           "Master skills with comprehensive practice.",
                           style: TextStyle(color: Colors.white70, fontSize: 18),
                         ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Center(
                    child: SizedBox(
                      width: 450,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        margin: const EdgeInsets.all(32),
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Welcome Back", 
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                              ),
                              const SizedBox(height: 8),
                              const Text("Please sign in to continue.", style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 32),
                              _buildLoginForm(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Scaffold(
          appBar: AppBar(
            title: const Text("Sign In", style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.primaryGreen,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildLoginForm(),
          ),
        );
      },
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min, // Important for the card layout
      children: [
        if (_error != null) 
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200)
            ),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: "Email",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
             style: ElevatedButton.styleFrom(
               backgroundColor: AppColors.primaryGreen,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               elevation: 2,
             ),
             onPressed: _isLoading ? null : _login,
             child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          child: RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.grey, fontSize: 14),
              children: [
                TextSpan(text: "Don't have an account? "),
                TextSpan(text: "Create one.", style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        )
      ],
    );
  }
}
