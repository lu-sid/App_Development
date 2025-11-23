import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // REGISTER (Email + Password)
  Future<User?> register(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'name': name,
      'email': email,
      'isPremium': false,
    });

    return cred.user;
  }

  // LOGIN (Email + Password)
  Future<User?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  // GOOGLE SIGN-IN LOGIN


  // PHONE — SEND OTP
  Future<void> sendOTP(String phone, Function(String) onCodeSent) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e.message ?? "Phone verification failed";
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  // PHONE — VERIFY OTP
  Future<User?> verifyOTP(String verificationId, String otp) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    final cred = await _auth.signInWithCredential(credential);

    final name = cred.user?.displayName ?? "User";
    final email = cred.user?.email ?? "";

    await _db.collection('users').doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'name': name,
      'email': email,
      'isPremium': false,
    }, SetOptions(merge: true));

    return cred.user;
  }

  // GET USER FROM FIRESTORE
  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data();
  }

  // LOGOUT
  Future<void> logout() async => await _auth.signOut();
}
