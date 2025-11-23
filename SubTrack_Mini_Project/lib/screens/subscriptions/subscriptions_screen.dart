import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/subscription_service.dart';
import '../../../models/subscription_model.dart';
import 'add_subscription_screen.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SubscriptionService();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // text color will follow theme
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark
        ? Colors.white.withOpacity(0.10)  // glassmorphic
        : Colors.white;                   // clean light card

    return StreamBuilder<List<SubscriptionModel>>(
      stream: service.getSubscriptions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading subscriptions ❌',
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 16),
            ),
          );
        }

        final subs = snapshot.data ?? [];
        if (subs.isEmpty) {
          return Center(
            child: Text(
              'No subscriptions yet 📭',
              style: GoogleFonts.poppins(fontSize: 16, color: textColor),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 100, top: 10),
          itemCount: subs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, i) {
            final sub = subs[i];

            return Dismissible(
              key: ValueKey(sub.id),
              direction: DismissDirection.endToStart,
              background: Container(
                padding: const EdgeInsets.only(right: 25),
                alignment: Alignment.centerRight,
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white, size: 32),
              ),
              confirmDismiss: (_) async {
                await service.deleteSubscription(sub.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${sub.name} deleted')),
                );
                return true;
              },
              child: Card(
                color: cardColor,
                elevation: isDark ? 0 : 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddSubscriptionScreen(existingSub: sub),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        // 🔥 Gradient icon (stays same for both themes)
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFff512f), Color(0xFFdd2476)],
                            ),
                          ),
                          child: const Icon(Icons.subscriptions, color: Colors.white),
                        ),
                        const SizedBox(width: 14),

                        // Title + price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${sub.price.toStringAsFixed(2)}",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Category pill (theme adaptive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.12)
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: isDark
                                ? Border.all(color: Colors.white24)
                                : null,
                          ),
                          child: Text(
                            sub.category,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white
                                  : Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
