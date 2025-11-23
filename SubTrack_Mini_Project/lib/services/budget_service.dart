import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetService {
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// 🔹 Stream budgets in realtime
  Stream<Map<String, double>> getBudgetsStream() {
    final uid = _auth.currentUser!.uid;
    return _fire.collection("users").doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null || !data.containsKey("budgets")) return {};
      final raw = data["budgets"] as Map<String, dynamic>;
      return raw.map((k, v) => MapEntry(k, (v as num).toDouble()));
    });
  }

  /// 🔹 Add or update budget for category — merge 🔥
  Future<void> setBudget(String category, double amount) async {
    final uid = _auth.currentUser!.uid;
    await _fire.collection("users").doc(uid).set({
      "budgets": {category: amount}
    }, SetOptions(merge: true));
  }

  /// 🔹 Remove a budget if user wants (optional future UI)
  Future<void> deleteBudget(String category) async {
    final uid = _auth.currentUser!.uid;
    await _fire.collection("users").doc(uid).update({
      "budgets.$category": FieldValue.delete(),
    });
  }

  /// 🔹 Reset all budgets (optional future UI)
  Future<void> clearAllBudgets() async {
    final uid = _auth.currentUser!.uid;
    await _fire.collection("users").doc(uid).update({
      "budgets": {},
    });
  }
}
