// lib/views/shared/main_drawer.dart (Final, Integrated Navigation - Yield Module Linked)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../view_models/auth_view_model.dart';
// Imports for all content screens
import '../home/home_dashboard_screen.dart';
import '../home/crop_list_screen.dart';
import '../home/weather_forecast_screen.dart';
import 'placeholder_screen.dart';
import 'profile_screen.dart';

// --- ADD ALL UTILITY & YIELD IMPORTS ---
import 'settings_screen.dart';
import 'about_screen.dart';
import 'help_support_screen.dart'; // Screen 20 (Help)
import '../yield/crop_yield_history_screen.dart'; // NEW: Link to Yield List (Screen 20)
// ----------------------------------------

abstract class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
}

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userEmail = authViewModel.currentUser?.email ?? 'N/A';
    final userName = authViewModel.currentUser?.displayName ?? 'Farmer';

    // Determine the text color for the sidebar based on the current theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final headerTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return Drawer(
      // CRITICAL FIX: Ensure Drawer background respects the dark theme canvas color
      child: Container(
        color: Theme.of(context).canvasColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // --- Drawer Header (User Info) ---
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.darkGreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(backgroundColor: Colors.white, radius: 30, child: Icon(Icons.person, color: AppColors.darkGreen, size: 30)),
                  const SizedBox(height: 8),
                  Text(userName, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(userEmail, style: GoogleFonts.roboto(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),

            // --- Main Modules ---
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text('Main Modules', style: GoogleFonts.roboto(color: headerTextColor, fontWeight: FontWeight.w500))
            ),
            _buildDrawerItem(context, icon: Icons.dashboard_rounded, title: 'Dashboard', screen: const HomeDashboardScreen()),
            _buildDrawerItem(context, icon: FontAwesomeIcons.pagelines, title: 'Crops Management', screen: const CropListScreen()),
            _buildDrawerItem(context, icon: Icons.cloud_queue, title: 'Weather Forecast', screen: const WeatherForecastScreen()),

            // --- FINAL LINK: Yield History (Screen 20) ---
            _buildDrawerItem(context, icon: FontAwesomeIcons.wheatAwn, title: 'Yield History', screen: PlaceholderScreen(title: 'Please select a crop first')), // Links to a Placeholder that requires a crop selection first
            const Divider(),

            // --- Account & Utility Links ---
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Text('Account & Utility', style: GoogleFonts.roboto(color: headerTextColor, fontWeight: FontWeight.w500))
            ),

            _buildDrawerItem(context, icon: Icons.person_outline, title: 'Your Profile', screen: const ProfileScreen()),
            _buildDrawerItem(context, icon: Icons.settings, title: 'Settings', screen: const SettingsScreen()),

            // --- Help & Support Link (Screen 20) ---
            _buildDrawerItem(context, icon: Icons.help_outline, title: 'Help & Support', screen: const HelpSupportScreen()),

            _buildDrawerItem(context, icon: Icons.info_outline, title: 'About AgroConnect', screen: const AboutScreen()),
            const Divider(),

            // --- Logout ---
            _buildDrawerItem(context, icon: Icons.exit_to_app, title: 'Logout', iconColor: Colors.red, onTap: () {
              Navigator.pop(context);
              authViewModel.signOut();
            }),
          ],
        ),
      ),
    );
  }

  // --- UNIFIED HELPER FUNCTION (Final Theme Logic) ---
  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, Widget? screen, VoidCallback? onTap, Color iconColor = AppColors.primaryGreen}) {
    // If the screen requires specific data (like Crop Yield History), we use the Placeholder
    // to guide the user unless a direct navigation is intended.
    final destinationScreen = (title == 'Yield History')
        ? PlaceholderScreen(title: 'Please select a crop from Crops Management to view Yield History.')
        : (screen ?? PlaceholderScreen(title: title));

    // Determine list tile text color based on the current theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final listTileTextColor = isDarkMode ? Colors.white70 : Colors.black;
    final logoutTextColor = isDarkMode ? Colors.red.shade400 : Colors.red;

    // Determine the icon color: Utility icons use darkGreen/white, Content icons use primaryGreen
    final finalIconColor = (title == 'Your Profile' || title == 'Settings' || title == 'Help & Support' || title == 'About AgroConnect' || title == 'Logout')
        ? (isDarkMode ? AppColors.primaryGreen : AppColors.darkGreen)
        : iconColor;

    return ListTile(
      leading: Icon(icon, color: finalIconColor),
      title: Text(
          title,
          style: GoogleFonts.roboto(
              fontSize: 16,
              // FIX: Apply dynamic color to all list item text
              color: title == 'Logout' ? logoutTextColor : listTileTextColor
          )
      ),
      // Set the tile color to respect the theme's background color (critical for dark mode)
      tileColor: Theme.of(context).canvasColor,
      onTap: onTap ?? () {
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => destinationScreen));
      },
    );
  }
}