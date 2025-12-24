// lib/views/shared/profile_screen.dart (Final Professional User Profile)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../view_models/auth_view_model.dart';

// Reusing constants
abstract class AppSpacing {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}

abstract class AppColors {
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color accentBlue = Color(0xFF42A5F5);
}


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the current user object securely
    final User? user = Provider.of<AuthViewModel>(context).currentUser;

    // Fallback if the user object is somehow null
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.darkGreen,
          title: Text('Profile', style: GoogleFonts.montserrat(color: Colors.white)),
        ),
        body: const Center(child: Text('Error: User data unavailable.', style: TextStyle(color: Colors.red))),
      );
    }

    // Format creation date for professional display
    final String memberSince = user.metadata.creationTime != null
        ? DateFormat('MMMM d, yyyy').format(user.metadata.creationTime!)
        : 'N/A';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text('Your Profile', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: SizedBox(
            width: 500, // Constrain width for professionalism
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Avatar ---
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                      child: const Icon(Icons.person_rounded, size: 60, color: AppColors.darkGreen),
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // --- User Name/Email ---
                    Text(
                      user.displayName ?? 'AgroConnect User',
                      style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.darkGreen),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      user.email ?? 'No email available',
                      style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey.shade700),
                    ),
                    const Divider(height: AppSpacing.large * 2),

                    // --- Account Details Grid ---
                    _buildDetailRow(
                      icon: Icons.date_range,
                      title: 'Member Since',
                      value: memberSince,
                    ),
                    _buildDetailRow(
                      icon: Icons.security,
                      title: 'Email Verified',
                      value: user.emailVerified ? 'Yes' : 'No',
                      color: user.emailVerified ? AppColors.primaryGreen : Colors.red,
                    ),
                    _buildDetailRow(
                      icon: Icons.vpn_key,
                      title: 'UID',
                      value: user.uid,
                      isUid: true,
                    ),

                    const SizedBox(height: AppSpacing.large),

                    // Button Placeholder (e.g., Change Password)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password change feature coming soon.')));
                        },
                        icon: const Icon(Icons.lock_outline, color: AppColors.accentBlue),
                        label: Text('Change Password', style: GoogleFonts.roboto(color: AppColors.accentBlue)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
                          side: const BorderSide(color: AppColors.accentBlue),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Final corrected helper function
  Widget _buildDetailRow({required IconData icon, required String title, required String value, Color? color, bool isUid = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.small),
      child: Row(
        crossAxisAlignment: isUid ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.darkGreen, size: 24),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: color ?? Colors.black,
              ),
              overflow: isUid ? TextOverflow.ellipsis : null,
              maxLines: isUid ? 2 : 1,
            ),
          ),
        ],
      ),
    );
  }
}