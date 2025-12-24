// lib/views/shared/help_support_screen.dart (Screen 20: Help & Support)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // REQUIRED for external links

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

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // --- External Link Handler ---
  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback for context that cannot launch (e.g., mailto in some web browsers)
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme awareness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text('Help & Support', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: SizedBox(
          width: 800,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Assistance?',
                  style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                ),
                const SizedBox(height: AppSpacing.large),

                // --- Contact Group ---
                _buildSettingsGroup(
                  context,
                  title: 'Contact Us',
                  children: [
                    _buildSimpleSetting(
                      context,
                      title: 'Email Support',
                      icon: Icons.email_outlined,
                      subtitle: 'agroconnect@support.com',
                      iconColor: AppColors.accentBlue,
                      onTap: () => _launchURL('mailto:agroconnect@support.com?subject=App%20Support%20Request'),
                    ),
                    const Divider(),
                    _buildSimpleSetting(
                      context,
                      title: 'Call Helpline',
                      icon: Icons.phone_outlined,
                      subtitle: '+92 312 3456789 (9AM - 5PM PKT)',
                      iconColor: AppColors.primaryGreen,
                      onTap: () => _launchURL('tel:+923123456789'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),

                // --- Resources Group ---
                _buildSettingsGroup(
                  context,
                  title: 'Resources',
                  children: [
                    _buildSimpleSetting(
                      context,
                      title: 'Frequently Asked Questions (FAQ)',
                      icon: Icons.question_answer_outlined,
                      subtitle: 'Find quick answers to common issues.',
                      iconColor: AppColors.primaryGreen,
                      onTap: () => _launchURL('https://agroconnect.com/faq'),
                    ),
                    const Divider(),
                    _buildSimpleSetting(
                      context,
                      title: 'Video Tutorials',
                      icon: FontAwesomeIcons.youtube,
                      subtitle: 'Watch guides on setting up crops and tasks.',
                      iconColor: Colors.red.shade700,
                      onTap: () => _launchURL('https://youtube.com/agroconnect-tutorials'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),

                // --- Version Info ---
                const Center(
                  child: Text(
                    'Smart AgroConnect v1.2.0\nDeveloped in 2025',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Methods (Adapted from Settings Screen) ---

  Widget _buildSettingsGroup(BuildContext context, {required String title, required List<Widget> children}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.medium, top: AppSpacing.medium / 2),
          child: Text(
            title,
            style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.darkGreen
            ),
          ),
        ),
        Card(
          elevation: 2,
          color: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleSetting(BuildContext context, {required String title, required IconData icon, required String subtitle, required Color iconColor, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: GoogleFonts.roboto(fontSize: 14)),
      leading: Icon(icon, color: iconColor),
      trailing: const Icon(Icons.open_in_new, size: 16, color: Colors.grey),
      onTap: onTap,
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}