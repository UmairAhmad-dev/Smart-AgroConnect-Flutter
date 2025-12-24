import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'; // kIsWeb is imported from here

// This file is manually created to overcome environment configuration issues.
// DO NOT COMMIT YOUR API KEYS TO PUBLIC REPOSITORIES.

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // 1. Check if running on Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Keys for Android
      return const FirebaseOptions(
        apiKey: 'AIzaSyALImtS-gyIHq6n_gvlDUZ5QjTKQiBdU-Y',
        appId: '1:172070214246:android:e3813246b5afa5cf7baba7',
        messagingSenderId: '172070214246',
        projectId: 'smartagroconnect-cb39a',
        storageBucket: 'smartagroconnect-cb39a.appspot.com',
      );
      // 2. Check if running on Web (Fixed with kIsWeb)
    } else if (kIsWeb) {
      // Keys for the WEB platform
      return const FirebaseOptions(
        apiKey: "AIzaSyBDxsq4fqsc3jmNL72eyP8DIpb6XYoHjaM",
        appId: '1:172070214246:web:f346ccbae457c74a7baba7',
        messagingSenderId: '172070214246',
        projectId: 'smartagroconnect-cb39a',
        authDomain: 'smartagroconnect-cb39a.firebaseapp.com',
        storageBucket: 'smartagroconnect-cb39a.firebasestorage.app',
      );
    }
    // Default/Placeholder configuration for other platforms
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }
}