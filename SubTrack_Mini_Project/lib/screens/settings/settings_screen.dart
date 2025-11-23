import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme_controller.dart';
import '../plans/plans_screen.dart';
import '../../services/auth_service.dart';
import '../profile/edit_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feedback_page.dart';
import 'help_support_page.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _cancelPremium(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({"isPremium": false});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("⛔ Premium canceled — switched to Free")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.isDarkMode;
    final userFuture = AuthService().getUserData();

    return Container(
      decoration: isDark
          ? const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF31005F), Color(0xFF0B071D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            )
          : null,
      child: Scaffold(
        backgroundColor: isDark ? Colors.transparent : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            "Settings",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⭐ Profile Card
              FutureBuilder(
                future: userFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 110,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final data = snapshot.data!;
                  final isPremium = data["isPremium"] == true;

                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: isDark ? Colors.white.withOpacity(0.10) : Colors.white,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.18)
                            : Colors.black12,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              isDark ? Colors.red : Colors.red.shade200,
                          child: const Icon(Icons.person,
                              size: 35, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data["name"],
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  )),
                              const SizedBox(height: 4),
                              Text(data["email"],
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  )),
                              const SizedBox(height: 4),
                              Text(
                                isPremium ? "💎 Premium Member" : "Free Member",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isPremium
                                      ? Colors.amber
                                      : (isDark ? Colors.white70 : Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: isDark ? Colors.white : Colors.black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
                FutureBuilder(
                  future: userFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    final data = snapshot.data!;
                    final isPremium = data["isPremium"] == true;
                    final streak = data["streak"] ?? 1;
                    final milestone = data["subsAdded"] ?? 0;

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDark ? Colors.white.withOpacity(0.12) : Colors.grey.shade100,
                        border: Border.all(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Achievements",
                              style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.local_fire_department_rounded,
                                  color: Colors.orange, size: 30),
                              const SizedBox(width: 10),
                              Text("🔥 $streak-day streak",
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: isDark ? Colors.white : Colors.black,
                                  )),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.workspace_premium_rounded,
                                  color: milestone >= 10 ? Colors.amber : Colors.grey, size: 30),
                              const SizedBox(width: 10),
                              Text(
                                milestone >= 10
                                    ? "🎉 Milestone reached — 10+ subscriptions!"
                                    : "$milestone subscriptions added",
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: isDark ? Colors.white : Colors.black),
                              ),
                            ],
                          ),
                          if (isPremium) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.star_rounded, color: Colors.amber, size: 30),
                                const SizedBox(width: 10),
                                Text("💎 Premium badge unlocked",
                                    style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: isDark ? Colors.white : Colors.black)),
                              ],
                            )
                          ]
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 28),

              _sectionTitle("Preferences", isDark),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)),
                child: SwitchListTile(
                  key: ValueKey(themeController.isDarkMode),
                  value: themeController.isDarkMode,
                  activeColor: Colors.red,
                  title: Text(
                    "Dark Mode",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  onChanged: (_) => themeController.toggleTheme(),
                ),
              ),


              _menuTile(
                icon: Icons.notifications_active,
                title: "Notifications",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Notification settings coming soon 🔔")));
                },
                isDark: isDark,
                iconColor: Colors.blueAccent,
              ),

              const SizedBox(height: 10),
              _sectionTitle("Premium", isDark),

              FutureBuilder(
                future: userFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final data = snapshot.data!;
                  final isPremium = data["isPremium"] == true;

                  return Column(
                    children: [
                      if (!isPremium)
                        _menuTile(
                          icon: Icons.upgrade,
                          title: "View Plans / Upgrade",
                          isDark: isDark,
                          iconColor: Colors.amber,
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => PlansScreen()));
                          },
                        ),
                      if (isPremium)
                        _menuTile(
                          icon: Icons.cancel,
                          title: "Cancel Premium Plan",
                          isDark: isDark,
                          iconColor: Colors.red,
                          onTap: () => _cancelPremium(context),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 10),
              _sectionTitle("Support", isDark),

              _menuTile(
                icon: Icons.support_agent_rounded,
                title: "Help & Support",
                iconColor: Colors.green,
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpSupportPage()),
                  );
                },
              ),

              _menuTile(
                icon: Icons.bug_report_rounded,
                title: "Report a Bug / Feedback",
                iconColor: Colors.deepOrange,
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedbackPage()),
                  );
                },
              ),

              _menuTile(
                icon: Icons.info_outline,
                title: "About App",
                isDark: isDark,
                iconColor: Colors.indigo,
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "SubTrack",
                    applicationVersion: "1.0.0",
                    applicationLegalese: "© 2025 SubTrack — All rights reserved.",
                  );
                },
              ),

              const SizedBox(height: 35),

              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text("Logout",
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white)),
                  onPressed: () async {
                    await AuthService().logout();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required bool isDark,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 15.5,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }
}
