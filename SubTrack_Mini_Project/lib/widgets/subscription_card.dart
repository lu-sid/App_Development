import 'package:flutter/material.dart';

class SubscriptionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const SubscriptionCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name']?.toString() ?? "Unnamed";
    final period = data['period']?.toString() ?? "Unknown";
    final amount = data['amount']?.toString() ?? "0";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$period plan",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          Text(
            "₹$amount",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
