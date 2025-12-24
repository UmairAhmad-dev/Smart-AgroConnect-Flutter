// lib/views/auth/auth_wrapper.dart (CORRECTED ROUTING)

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../view_models/auth_view_model.dart';
import '../home/main_home_shell.dart'; // <--- UPDATED: Import the new Shell
import 'login_screen.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // StreamBuilder listens to the state of the user (logged in or out)
    return StreamBuilder<User?>(
      stream: authViewModel.authStateChanges,
      builder: (context, snapshot) {
        // Show a loading circle while checking the initial status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50), // Green 500
              ),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          // User is NOT signed in, show the login screen (or an initial welcome screen)
          return const LoginScreen();
        } else {
          // User is signed in, show the professional Main Home Shell
          return const MainHomeShell(); // <--- UPDATED ROUTE
        }
      },
    );
  }
}