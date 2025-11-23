import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  Future<void> _submit() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection("feedback").add({
      "uid": user?.uid,
      "message": _ctrl.text.trim(),
      "time": DateTime.now(),
    });

    setState(() => _sending = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thanks for your feedback 💙")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Feedback"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Tell us about any bug or request a feature",
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _ctrl,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Write here...",
                filled: true,
                fillColor: isDark ? Colors.white10 : Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _sending ? null : _submit,
              icon: const Icon(Icons.send),
              label: Text(
                _sending ? "Sending..." : "Submit",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
