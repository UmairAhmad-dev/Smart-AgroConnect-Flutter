// lib/view_models/auth_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_data.dart'; // Import the model we just created

class AuthViewModel with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // States
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _auth.currentUser; // Get currently logged-in user

  // Stream to track auth changes (used by AuthWrapper)
  Stream<User?> get authStateChanges => _auth.authStateChanges();


  // --- Helper Methods ---

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }


  // --- Backend Integration: Sign Up ---

  Future<bool> signUp({required String email, required String password, required String displayName}) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a new UserData object
      UserData newUser = UserData(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
      );

      // Write the user's profile to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set(newUser.toMap());

      _setLoading(false);
      return true; // Success
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(e.message ?? 'An unknown error occurred during signup.');
      _setLoading(false);
      return false; // Failure
    } catch (e) {
      _setErrorMessage('An unexpected error occurred: $e');
      _setLoading(false);
      return false; // Failure
    }
  }


  // --- Backend Integration: Sign In ---

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _setLoading(false);
      return true; // Success
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(e.message ?? 'Login failed. Please check credentials.');
      _setLoading(false);
      return false; // Failure
    } catch (e) {
      _setErrorMessage('An unexpected error occurred: $e');
      _setLoading(false);
      return false; // Failure
    }
  }


  // --- Backend Integration: Change Password (NEW METHOD) ---
  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User is not logged in or session expired.");
    }

    // NOTE: This relies on the current session token. If the token is too old,
    // Firebase will throw an error requiring recent login.
    try {
      await user.updatePassword(newPassword);
      // The calling screen will handle the success message.
    } on FirebaseAuthException catch (e) {
      // Re-throw specific errors for the UI to handle
      throw Exception(e.message ?? "Failed to update password.");
    }
  }


  // --- Backend Integration: Sign Out ---

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _auth.signOut();
    } catch (e) {
      // Handle sign out errors if necessary
      if (kDebugMode) {
        print("Error during sign out: $e");
      }
    } finally {
      _setLoading(false);
    }
  }
}