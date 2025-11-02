import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. User Registration (Example)
  Future<User?> registerWithEmailPassword(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // Store user profile details in Firestore
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      // FIX: Instead of printing and returning null, re-throw the exception.
      // This allows the UI to catch the specific error and show a user-friendly message.
      rethrow;
    }
  }

  // 2. User Login (Example)
  Stream<User?> get user => _auth.authStateChanges();
  
  // (You would add a separate login function here similar to register)
}