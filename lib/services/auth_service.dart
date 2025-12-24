import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Real-time stream to listen for user sign-in/out status
  Stream<User?> get user => _auth.authStateChanges();

  // --- 1. SIGN IN (LOGIN) ---
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Throw the error message for the ViewModel to catch and display
      throw e.message ?? 'Login failed. Check credentials.';
    }
  }

  // --- 2. SIGN UP (REGISTER) ---
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // 1. Create user in Firebase Authentication
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user != null) {
        // 2. Create a user profile document in Firestore (for storing details like fullName, role)
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'fullName': fullName,
          'role': 'farmer',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Registration failed.';
    }
  }

  // --- 3. SIGN OUT ---
  Future<void> signOut() async {
    await _auth.signOut();
  }
}