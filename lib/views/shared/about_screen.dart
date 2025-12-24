// lib/views/shared/about_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Reusing constants
abstract class AppColors {
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color primaryGreen = Color(0xFF4CAF50);
}

abstract class AppSpacing {
  static const double medium = 16.0;
  static const double large = 24.0;
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text('About AgroConnect', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: SizedBox(
          width: 600,
          child: Card(
            margin: const EdgeInsets.all(AppSpacing.large),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.large),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.agriculture_sharp, size: 80, color: AppColors.primaryGreen),
                  const SizedBox(height: AppSpacing.medium),
                  Text('AgroConnect', style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                  Text('Version 1.0.0 (Professional Release)', style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey.shade600)),
                  const SizedBox(height: AppSpacing.large),

                  Text(
                    'AgroConnect is a comprehensive digital platform designed to optimize modern farming operations. It provides real-time crop management, accurate weather forecasting, and market trend analysis to help farmers make data-driven decisions.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.large),

                  ListTile(
                    leading: const Icon(Icons.code, color: AppColors.darkGreen),
                    title: Text('Developed with Flutter and Firebase', style: GoogleFonts.roboto()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email, color: AppColors.darkGreen),
                    title: Text('Support: support@agroconnect.com', style: GoogleFonts.roboto()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}