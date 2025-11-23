import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final String? id;
  final String name;
  final double price;
  final String date;
  final String category;
  final String reminder;      // 🔥 NEW FIELD

  SubscriptionModel({
    this.id,
    required this.name,
    required this.price,
    required this.date,
    required this.category,
    required this.reminder,   // 🔥 NEW
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "price": price,
      "date": date,
      "category": category,
      "reminder": reminder,  // 🔥 save to Firestore
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map, String id) {
    return SubscriptionModel(
      id: id,
      name: map["name"] ?? "",
      price: (map["price"] ?? 0).toDouble(),
      date: map["date"] ?? "",
      category: map["category"] ?? "",
      reminder: map["reminder"] ?? "No reminder", // 🔥 default if not stored before
    );
  }
}
