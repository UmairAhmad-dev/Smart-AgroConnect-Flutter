// lib/views/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view_models/auth_view_model.dart';
import 'auth/auth_wrapper.dart'; // We will use AuthWrapper for the main routing

// Reuse Spacing and Colors definitions for consistency
abstract class AppSpacing {
  static const double xsmall = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double xlarge = 32.0;
}

abstract class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color textBody = Color(0xFF424242);
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Start the timer to navigate after a short delay
    _startAppInitialization();
  }

  void _startAppInitialization() async {
    // 1. Simulate a delay for branding/loading (e.g., 2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    // 2. Navigate to the AuthWrapper, which handles the final routing (Login or Home)
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground, // Clean, light background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // --- 1. Logo and Branding ---
            Image.asset(
              'lib/assets/images/logo.png', // Assuming logo.png is defined here
              height: 150,
            ),
            const SizedBox(height: AppSpacing.large),
            Text(
              'Smart AgroConnect',
              style: GoogleFonts.montserrat(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                  letterSpacing: 1.5
              ),
            ),
            const SizedBox(height: AppSpacing.xlarge),

            // --- 2. Loading Indicator ---
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}