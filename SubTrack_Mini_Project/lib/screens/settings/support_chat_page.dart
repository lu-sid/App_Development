import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  /// 🔹 Auto replies for keyword detection
  final Map<String, String> autoReplies = {
  // Billing / Premium
  "premium": "💎 SubTrack Premium gives you unlimited subscriptions, complete access to Smart Analytics, PDF Export, AI insights, and priority customer support. It’s designed for users managing multiple bills and wanting full financial clarity.",
  "price": "📌 The cost of SubTrack Premium is kept affordable compared to other budgeting apps. You pay once per year and get full access to all premium features without hidden fees.",
  "upgrade": "🚀 You can upgrade to Premium anytime from the *Plans* page inside the app. Your premium benefits activate instantly after successful payment — no waiting time.",
  "cancel premium": "⚠ You can cancel Premium anytime. After cancellation, you’ll continue enjoying Premium until your billing cycle ends — nothing stops immediately.",
  "expiry": "⏳ To check your plan expiry date, go to *Dashboard → Membership Details*. The expiry date and plan type will be displayed there.",

  // Account / Login
  "login": "🔐 If you are facing login issues: (1) Make sure your internet is stable, (2) Try closing and reopening the app, (3) If it still fails, reset your password. Most login issues are solved using these steps.",
  "password": "🔑 You can reset your password directly using the *Forgot Password* button on the Login screen. A reset link will be emailed to you instantly.",
  "otp": "📨 OTP and verification emails can take 30–60 seconds to arrive. If you don’t find them in Inbox, please also check *Spam / Promotions* folder.",
  "email change": "📧 For security reasons, email changes must be requested via support. Share your current email + new email and we’ll update it manually.",
  "delete account": "⚠ Account deletion is done manually to ensure privacy. Once deleted, all subscription data is permanently removed — this action cannot be undone.",

  // Payments / Refund
  "refund": "💸 Refund requests are reviewed individually. After approval, it typically takes 5–7 business days for the amount to reflect back in your original payment method.",
  "payment": "💳 If your payment failed, try the following: (1) Restart the app, (2) Try a different payment method, (3) Check if your bank app is online. If money was debited but premium did not activate, share a screenshot and we’ll fix it.",
  "upi": "📲 UPI payments sometimes take 20–30 seconds to confirm. If your plan doesn’t activate instantly, it usually triggers automatically within a short time.",
  "transaction": "📌 If a transaction was successful but Premium didn’t activate, please share the payment screenshot. We’ll verify and activate the plan manually for you.",

  // Bugs / Errors
  "bug": "🐞 Thanks for reporting a bug! To fix it faster, please share steps to reproduce the issue + (if possible) a screenshot or screen recording.",
  "error": "⚠ Sorry for the inconvenience! Let us know where the error appears and what action you were taking at that moment — it helps us locate the cause.",
  "crash": "💥 If the app crashes frequently, it may be due to low RAM or low device storage. Clearing storage or reinstalling usually helps. If it continues, we’ll investigate further.",
  "lag": "🐢 Lag can happen when multiple heavy apps are running in the background. Our team is also working on performance improvements in upcoming updates.",
  "slow": "🐌 Slow response usually improves after clearing cache or reinstalling the app. If the issue remains, tell us your device model and OS version so we can optimize for it.",

    // Features & Info
    "subscription": "🧾 Subscriptions are grouped by category and billing date.",
    "category": "📌 Categories: Entertainment / Education / Productivity / Other.",
    "analytics": "📈 Analytics compare spending by month & category.",
    "pdf": "📑 PDF export for analytics & expense reports is coming soon!",
    "backup": "☁ Cloud backup ensures data stays safe across devices.",
    "dashboard": "📊 Dashboard updates instantly when you add/edit subscriptions.",
    "streak": "🔥 Spending streaks coming soon — you're gonna love it!",
// 🔹 Features & Info
    "features":
    "✨ SubTrack Features:\n\n"
    "- 🔔 Subscription reminders (1 / 3 / 7 days early)\n"
    "- 💰 Track bills & monthly expenses\n"
    "- 📊 Smart analytics dashboard\n"
    "- 🎨 Dark/Light theme support\n"
    "- 🧾 Auto-category classification\n"
    "- 💎 Premium: unlimited subscriptions\n"
    "- 📝 PDF export (coming soon)\n"
    "- 🔥 Spending streaks (coming soon)\n\n"
    "Tell us if you want to suggest a new feature 😊",

    "feature list":
    "✨ SubTrack Features:\n\n"
    "- 🔔 Subscription reminders (1 / 3 / 7 days early)\n"
    "- 💰 Track bills & monthly expenses\n"
    "- 📊 Smart analytics dashboard\n"
    "- 🎨 Dark/Light theme support\n"
    "- 🧾 Auto-category classification\n"
    "- 💎 Premium: unlimited subscriptions\n"
    "- 📝 PDF export (coming soon)\n"
    "- 🔥 Spending streaks (coming soon)\n\n"
    "Tell us if you want to suggest a new feature 😊",

    "app features":
    "✨ SubTrack Features:\n\n"
    "- 🔔 Subscription reminders (1 / 3 / 7 days early)\n"
    "- 💰 Track bills & monthly expenses\n"
    "- 📊 Smart analytics dashboard\n"
    "- 🎨 Dark/Light theme support\n"
    "- 🧾 Auto-category classification\n"
    "- 💎 Premium: unlimited subscriptions\n"
    "- 📝 PDF export (coming soon)\n"
    "- 🔥 Spending streaks (coming soon)\n\n"
    "Tell us if you want to suggest a new feature 😊",


    // Notifications
    "notification": "🔔 Ensure device notifications are enabled for reminders.",
    "reminder": "⏰ Reminder options: On day / 1 day before / 3 days before / 7 days before.",

    // General / Greetings
    "help": "🆘 We're here to help — describe the issue.",
    "support": "🤝 A support agent will join soon. Meanwhile tell us the issue.",
    "hello": "👋 Hi there! How can we help?",
    "hi": "👋 Hey! What do you need help with?",
    "thanks": "😊 Anytime! Tell us if you need anything else.",
    "thank you": "🙏 You're welcome! Happy to assist 💙",
  };

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    // Send user message
    await FirebaseFirestore.instance.collection("supportChat").add({
      "uid": uid,
      "message": text,
      "timestamp": DateTime.now(),
    });

    _msgCtrl.clear();

    // 🔹 Auto reply keyword detection
    // 🔹 Auto reply keyword detection + fallback
bool replied = false;

for (final keyword in autoReplies.keys) {
  if (text.toLowerCase().contains(keyword)) {
    replied = true;
    Future.delayed(const Duration(milliseconds: 450), () async {
      await FirebaseFirestore.instance.collection("supportChat").add({
        "uid": "BOT",
        "message": autoReplies[keyword]!,
        "timestamp": DateTime.now(),
      });
    });
    break;
  }
}

// 🔥 If no keyword matched → send fallback help message
if (!replied) {
  Future.delayed(const Duration(milliseconds: 600), () async {
    await FirebaseFirestore.instance.collection("supportChat").add({
      "uid": "BOT",
      "message":
          "🤖 Thanks for your message! A support agent will review it soon.\nMeanwhile, could you please describe the issue in more detail (steps, screenshot, error message etc.)? This helps us solve it faster 💙",
      "timestamp": DateTime.now(),
    });
  });
}


    // Scroll to last message
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
          title: Text(
            "Live Chat Support 💬",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 19,
            ),
          ),
        ),

        body: Column(
          children: [
            // 🔹 Messages list
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("supportChat")
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    controller: _scrollCtrl,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final bool isMe = msg["uid"] == uid;
                      final bool isBot = msg["uid"] == "BOT";

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: isMe
                                ? const LinearGradient(
                                    colors: [Color(0xFFE50914), Color(0xFFB20710)],
                                  )
                                : isBot
                                    ? const LinearGradient(
                                        colors: [Color(0xFF1FB3FF), Color(0xFF0084FF)],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.white10,
                                          Colors.white24,
                                        ],
                                      ),
                            border: Border.all(
                              color: isMe
                                  ? Colors.white.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.22),
                            ),
                          ),
                          child: Text(
                            msg["message"],
                            style: GoogleFonts.poppins(
                              fontSize: 14.2,
                              color: Colors.white,
                              height: 1.32,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // 🔹 Suggested Quick Issue Chips
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10, top: 6),
              child: SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _quickChip("premium", Icons.workspace_premium),
                    _quickChip("payment", Icons.payment_rounded),
                    _quickChip("login", Icons.lock_open_rounded),
                    _quickChip("bug", Icons.bug_report_rounded),
                    _quickChip("refund", Icons.currency_rupee),
                    _quickChip("features", Icons.lightbulb_outline),
                  ],
                ),
              ),
            ),

            // 🔹 Chat Input
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                ),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.15)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.redAccent,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: GoogleFonts.poppins(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                              const BorderSide(color: Color(0xFFE50914), width: 1.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE50914), Color(0xFFB20710)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.5),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Reusable quick chip widget
  Widget _quickChip(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          _msgCtrl.text = text;
          _sendMessage();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
