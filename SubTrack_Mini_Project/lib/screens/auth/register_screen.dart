import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true; // show/hide password

  Future<void> _register() async {
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthService().register(
        _nameCtrl.text.trim(),
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful 🎉")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Registration failed";
      if (e.code == "email-already-in-use") {
        errorMsg = "Email already registered.";
      } else if (e.code == "weak-password") {
        errorMsg = "Password must be at least 6 characters.";
      } else if (e.code == "invalid-email") {
        errorMsg = "Enter a valid email address.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration fieldStyle(String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white12,
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.trending_up, color: Colors.red, size: 160),
                const SizedBox(height: 10),

                Text(
                  "SubTrack",
                  style: GoogleFonts.poppins(
                    fontSize: 34,
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 40),

                // Full Name field
                TextField(
                  controller: _nameCtrl,
                  cursorColor: Colors.red,
                  style: const TextStyle(color: Colors.white),
                  decoration: fieldStyle("Full Name"),
                ),
                const SizedBox(height: 18),

                // Email field
                TextField(
                  controller: _emailCtrl,
                  cursorColor: Colors.red,
                  style: const TextStyle(color: Colors.white),
                  decoration: fieldStyle("Email"),
                ),
                const SizedBox(height: 18),

                // Password with hide/show toggle
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  cursorColor: Colors.red,
                  style: const TextStyle(color: Colors.white),
                  decoration: fieldStyle("Password").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Register button
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.red)
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _register,
                          child: Text(
                            "Register",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Already have an account? Login",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
