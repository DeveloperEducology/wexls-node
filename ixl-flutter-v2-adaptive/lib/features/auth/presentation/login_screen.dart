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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign In", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (_error != null) 
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade100,
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                 style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                 onPressed: _isLoading ? null : _login,
                 child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text("Don't have an account? Create one."),
            )
          ],
        ),
      ),
    );
  }
}
