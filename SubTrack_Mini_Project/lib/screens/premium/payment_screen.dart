import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentScreen extends StatelessWidget {
  final String planName;
  final int validityInDays;

  const PaymentScreen({
    super.key,
    required this.planName,
    required this.validityInDays,
  });

  Future<void> _completePayment(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final expiry = DateTime.now().add(Duration(days: validityInDays));

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({
      "isPremium": true,
      "premiumExpiry": expiry.millisecondsSinceEpoch,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "🎉 Payment successful — Premium activated for $validityInDays days",
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Fixed price based on selected plan
    late double price;
    if (planName == "Basic Plan") {
      price = 99;
    } else if (planName == "Premium Plan") {
      price = 249;
    } else if (planName == "Elite Plan") {
      price = 799;
    } else {
      price = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Secure Checkout", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF330055), Color(0xFF0B051F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Column(
          children: [
            const SizedBox(height: 22),

            // 💎 Premium Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white24),
                color: Colors.white.withOpacity(0.07),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(planName,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 6),
                  Text(
                    "Validity: $validityInDays days",
                    style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),

                  // Payment breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Plan cost", style: GoogleFonts.poppins(color: Colors.white70)),
                      Text("₹${price.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Taxes & charges", style: GoogleFonts.poppins(color: Colors.white70)),
                      Text("₹0.00",
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          )),
                      Text("₹${price.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          )),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ⚠ Safety notice
            Text(
              "⚠ This is a demo purchase — No actual payment will be made.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 20),

            // Pay Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _completePayment(context),
                child: Text(
                  "Pay Now",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
