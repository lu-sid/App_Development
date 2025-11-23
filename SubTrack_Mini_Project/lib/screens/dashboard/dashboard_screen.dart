import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/subscription_service.dart' as subs;
import '../subscriptions/subscriptions_screen.dart';
import '../subscriptions/add_subscription_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';
import '../../services/auth_service.dart';
import '../../core/theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../plans/plans_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int subscriptionCount = 0;
  final service = subs.SubscriptionService();

  @override
  void initState() {
    super.initState();
    _updateSubscriptionCount();
  }

  Future<void> _updateSubscriptionCount() async {
    subscriptionCount = await service.getSubscriptionCount();
    setState(() {});
  }

  final List<Widget> pages = const [
    SubscriptionsScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: FadeInDown(
            child: Text(
              "Dashboard",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true,
        ),

        drawer: _buildDrawer(),

        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data()!;
            final userName = data["name"] ?? "";
            final isPremium = data["isPremium"] ?? false;
            final premiumExpiry = data["premiumExpiry"] ?? "—";
            final double usage =
                isPremium ? 1.0 : (subscriptionCount / 2).clamp(0.0, 1.0);

            return _selectedIndex == 0
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInLeft(
                          duration: const Duration(milliseconds: 700),
                          child: Text(
                            "Welcome, $userName 👋",
                            style: GoogleFonts.poppins(
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        if (isPremium)
                          ZoomIn(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFCCB2E), Color(0xFFFFF4C2)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.55),
                                    blurRadius: 14,
                                    spreadRadius: 2,
                                  )
                                ],
                              ),
                              child: Text(
                                "💎 Premium Member",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),

                        if (isPremium) const SizedBox(height: 4),
                        if (isPremium)
                          Text(
                            "⏳ Expires: ${premiumExpiry is Timestamp
                                ? DateFormat('dd MMM yyyy').format(premiumExpiry.toDate())
                                : premiumExpiry}",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),




                        const SizedBox(height: 26),

                        FadeIn(
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isPremium
                                      ? "Unlimited Subscriptions"
                                      : "Subscriptions used: $subscriptionCount / 2",
                                  style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: LinearProgressIndicator(
                                    value: usage,
                                    minHeight: 10,
                                    backgroundColor: Colors.white10,
                                    color: isPremium
                                        ? Colors.amber
                                        : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),
                        Expanded(child: const SubscriptionsScreen()),
                      ],
                    ),
                  )
                : pages[_selectedIndex];
          },
        ),

        floatingActionButton: ZoomIn(
          duration: const Duration(milliseconds: 450),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              child: const Icon(Icons.add, size: 28),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddSubscriptionScreen()),
                );
                _updateSubscriptionCount();
              },
            ),
          ),
        ),

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF24003F), Color(0xFF0A051C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.redAccent,
            unselectedItemColor: Colors.white70,
            elevation: 0,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt_outlined), label: "Subscriptions"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.pie_chart_outline), label: "Analytics"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined), label: "Settings"),
            ],
          ),
        ),
      ),
    );
  }

  /// ⬇ updated drawer tile text color only
  Widget _drawerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.redAccent),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.white, // ← changed here
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDrawer() {
    final themeController = Provider.of<ThemeController>(context);
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final data = snapshot.data!.data()!;
        final userName = data["name"] ?? "";
        final userEmail = data["email"] ?? "";
        final isPremium = data["isPremium"] ?? false;

        return Drawer(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF350064), Color(0xFF0B061D)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE50914), Color(0xFFB20710)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(userName,
                          style: GoogleFonts.poppins(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(userEmail,
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.white)), // was white70
                      const SizedBox(height: 8),
                      Text(
                        isPremium ? "💎 Premium Member" : "Free Member",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: isPremium ? Colors.amber : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                _drawerTile(Icons.star_rate, "Plans / Upgrade", () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => PlansScreen()));
                }),

                if (isPremium)
                  _drawerTile(Icons.cancel, "Cancel Premium", () async {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(user.uid)
                        .update({"isPremium": false, "premiumExpiry": "—"});
                  }),

                _drawerTile(Icons.settings_outlined, "Settings", () {
                  setState(() => _selectedIndex = 2);
                  Navigator.pop(context);
                }),

                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode, color: Colors.white),
                  title: Text(
                    "Dark Mode",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white, // ← changed here
                    ),
                  ),
                  value: themeController.isDarkMode,
                  onChanged: (value) => themeController.toggleTheme(),
                ),

                const Divider(color: Colors.white24),
                _drawerTile(Icons.logout, "Logout", () async {
                  await AuthService().logout();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
