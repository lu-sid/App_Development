import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../premium/payment_screen.dart';   // ⬅️ make sure this import exists

class PlansScreen extends StatelessWidget {
  PlansScreen({super.key});

  final List<Map<String, dynamic>> plans = [
    {
      'name': 'Basic Plan',
      'price': '₹99 / month',
      'color': Colors.blue,
      'days': 30,
      'features': [
        '1 user account',
        '5 GB cloud storage',
        'Email support',
      ]
    },
    {
      'name': 'Premium Plan',
      'price': '₹249 / 3 months',
      'color': Colors.red,
      'days': 90,
      'features': [
        '5 user accounts',
        '100 GB cloud storage',
        'Priority support',
      ]
    },
    {
      'name': 'Elite Plan',
      'price': '₹799 / year',
      'color': Colors.purple,
      'days': 365,
      'features': [
        'Unlimited accounts',
        '1 TB cloud storage',
        'Dedicated support',
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text("Choose Your Plan", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3E0075), Color(0xFF0A0425)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(18, 100, 18, 20),
          itemCount: plans.length,
          itemBuilder: (context, i) {
            final plan = plans[i];

            return Container(
              margin: const EdgeInsets.only(bottom: 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white.withOpacity(0.12),
                border: Border.all(color: Colors.white30, width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: plan['color'].withOpacity(0.4),
                    blurRadius: 22,
                    spreadRadius: 1,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [plan['color'], plan['color'].withOpacity(0.6)],
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            plan['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan['price'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Features
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Column(
                        children: List.generate(plan['features'].length, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    plan['features'][index],
                                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                        width: 160,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: plan['color'],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentScreen(
                                  planName: plan['name'],
                                  validityInDays: plan['days'],
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Choose Plan",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
