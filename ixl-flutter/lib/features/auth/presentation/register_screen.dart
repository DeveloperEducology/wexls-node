import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/supabase_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await SupabaseService().signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );
      // Auto login usually happens on signup in Supabase unless email confirm is on.
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
           _error = "Registration failed: ${e.toString()}";
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
                         const Icon(Icons.person_add_alt_1, size: 120, color: Colors.white),
                         const SizedBox(height: 32),
                         const Text(
                           "Join IXL Learning",
                           style: TextStyle(
                             color: Colors.white,
                             fontSize: 40,
                             fontWeight: FontWeight.bold,
                             letterSpacing: 1.2
                           )
                         ),
                         const SizedBox(height: 16),
                         const Text(
                           "Start your learning journey today.",
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
                      width: 500,
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
                                "Create Profile", 
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                              ),
                              const SizedBox(height: 8),
                              const Text("Please fill in your details.", style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 32),
                              SizedBox(
                                height: 500, // Limit height for scrollable form within card
                                child: SingleChildScrollView(
                                  child: _buildRegisterForm(),
                                ),
                              ),
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
            title: const Text("Create User Profile", style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.primaryGreen,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: _buildRegisterForm(),
          ),
        );
      },
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) 
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200)
            ),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: "Full Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
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
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: "Phone Number",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
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
          height: 50,
          child: ElevatedButton(
             style: ElevatedButton.styleFrom(
               backgroundColor: AppColors.primaryGreen,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               elevation: 2,
             ),
             onPressed: _isLoading ? null : _register,
             child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Text("Create Profile", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.grey, fontSize: 14),
              children: [
                TextSpan(text: "Already have an account? "),
                TextSpan(text: "Sign in.", style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        )
      ],
    );
  }
}
