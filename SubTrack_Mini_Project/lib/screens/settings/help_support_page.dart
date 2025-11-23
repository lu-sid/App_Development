import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'support_chat_page.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF31005F), Color(0xFF0B071D)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("Help & Support",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
          child: Column(
            children: [
              _supportCard(
                context,
                title: "📩 Contact Support",
                description: "Reach out to us for technical issues, bug reports or account queries.",
                buttonText: "Send Email",
                onTap: () {
                  /// Just action example (you can replace with email launcher)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Support email opening soon...")),
                  );
                },
              ),
              const SizedBox(height: 18),
              _supportCard(
                context,
                title: "💬 Online Chat Support",
                description: "Chat with support team for instant help.",
                buttonText: "Start Chat",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SupportChatPage()),
                  );
                },
              ),

              const SizedBox(height: 18),
              _supportCard(
                context,
                title: "🧠 FAQs",
                description: "Find answers to the most frequently asked questions.",
                buttonText: "View FAQs",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("FAQ section coming soon 📌")),
                  );
                },
              ),
              const SizedBox(height: 18),
              _supportCard(
                context,
                title: "❗ Troubleshooting",
                description: "Facing issues? Try app reset, re-login, or reinstall suggestions.",
                buttonText: "Open Tips",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Troubleshooting coming soon 🔧")),
                  );
                },
              ),
              const SizedBox(height: 18),
              _supportCard(
                context,
                title: "💬 Community",
                description: "Join the SubTrack community for suggestions & feature discussions.",
                buttonText: "Join",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Community feature coming soon 🌍")),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _supportCard(
      BuildContext context, {
        required String title,
        required String description,
        required String buttonText,
        required VoidCallback onTap,
      }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            child: Text(buttonText,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          )
        ],
      ),
    );
  }
}
