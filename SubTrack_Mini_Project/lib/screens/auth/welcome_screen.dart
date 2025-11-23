import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // // 🔥 Animation
            // Lottie.asset(
            //   "assets/animations/subtrack.json",
            //   height: 250,
            //   fit: BoxFit.contain,
            // ),
            const Icon(Icons.trending_up, color: Colors.red, size: 180),
            const SizedBox(height: 20),

            // 🔥 App Title
            const Text(
              "SubTrack",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 12),

            // 🔥 Subtitle
            const Text(
              "Track. Manage. Save.\nYour subscriptions in one place.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 50),

            // 🔥 Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔥 Signup Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
