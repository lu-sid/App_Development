import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subscription_model.dart';

class SubscriptionService {
  final _subs = FirebaseFirestore.instance.collection("subscriptions");

  Stream<List<SubscriptionModel>> getSubscriptions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _subs
        .where("userId", isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubscriptionModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addSubscription(SubscriptionModel sub) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = await _subs.add({
      ...sub.toMap(),
      "userId": user.uid, // IMPORTANT for rules
    });

    await ref.update({"id": ref.id});
  }

  Future<void> deleteSubscription(String id) async {
    await _subs.doc(id).delete();
  }

  Future<void> updateSubscription(SubscriptionModel sub) async {
    await _subs.doc(sub.id).update(sub.toMap());
  }

  Future<int> getSubscriptionCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;

    final q = await _subs.where("userId", isEqualTo: user.uid).get();
    return q.docs.length;
  }
}
