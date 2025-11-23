import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true; // 👈 REQUIRED for visibility toggle

  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  void _checkLoggedIn() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      });
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final user = await _auth.login(
        _email.text.trim(),
        _password.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";

      switch (e.code) {
        case 'user-not-found':
          message = "No user found with this email.";
          break;
        case 'wrong-password':
          message = "Incorrect password.";
          break;
        case 'invalid-email':
          message = "Invalid email format.";
          break;
        case 'user-disabled':
          message = "Account disabled.";
          break;
        case 'invalid-credential':
          message = "Credentials expired.";
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unexpected Error"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

                // Email input
                TextField(
                  controller: _email,
                  cursorColor: Colors.red,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white12,
                    hintText: "Email",
                    hintStyle: const TextStyle(color: Colors.white38),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Password input + visibility toggle
                TextField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  cursorColor: Colors.red,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white12,
                    hintText: "Password",
                    hintStyle: const TextStyle(color: Colors.white38),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Login button
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
                          onPressed: _login,
                          child: Text(
                            "Login",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text(
                    "Don't have an account? Register",
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