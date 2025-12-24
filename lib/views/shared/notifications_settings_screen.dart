// lib/views/shared/notifications_settings_screen.dart (Screen 16: Notifications Settings)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // REQUIRED for Provider
import '../../view_models/notifications_view_model.dart'; // REQUIRED for ViewModel

// Reusing constants
abstract class AppSpacing {
  static const double medium = 16.0;
  static const double large = 24.0;
}

abstract class AppColors {
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color primaryGreen = Color(0xFF4CAF50);
}


class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  // --- DELETED: Local state variables are replaced by ViewModel getters ---

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Consume the ViewModel to get and save preferences
    return Consumer<NotificationsViewModel>(
      builder: (context, viewModel, child) {
        // Theme awareness for UI elements
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.darkGreen,
            title: Text('Notification Settings', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          body: Center(
            child: SizedBox(
              width: 600,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.large),
                children: [
                  // --- Push Notification Group ---
                  _buildSettingsGroup(
                    context,
                    title: 'Global Preferences',
                    children: [
                      _buildToggleSetting(
                        context,
                        title: 'Allow Push Notifications',
                        icon: Icons.notifications_active_outlined,
                        value: viewModel.allowPushNotifications, // Use ViewModel getter
                        onChanged: (value) {
                          viewModel.updatePreference('allowPushNotifications', value); // Save to Firestore
                          _showFeedback(value ? 'Push notifications enabled.' : 'Push notifications disabled.');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.large),

                  // --- Task & Safety Alerts Group ---
                  _buildSettingsGroup(
                    context,
                    title: 'Task & Safety Alerts',
                    children: [
                      _buildToggleSetting(
                        context,
                        title: 'Overdue Task Warnings',
                        icon: Icons.access_time_filled,
                        value: viewModel.taskOverdueAlerts, // Use ViewModel getter
                        onChanged: (value) {
                          viewModel.updatePreference('taskOverdueAlerts', value); // Save to Firestore
                        },
                      ),
                      const Divider(),
                      _buildToggleSetting(
                        context,
                        title: 'Critical Weather Alerts',
                        icon: Icons.thunderstorm_outlined,
                        value: viewModel.weatherAlertsEnabled, // Use ViewModel getter
                        onChanged: (value) {
                          viewModel.updatePreference('weatherAlertsEnabled', value); // Save to Firestore
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.large),

                  // --- Email Reports Group ---
                  _buildSettingsGroup(
                    context,
                    title: 'Email Reports',
                    children: [
                      _buildToggleSetting(
                        context,
                        title: 'Weekly Financial Summary',
                        icon: Icons.email_outlined,
                        value: viewModel.financialSummaryEmails, // Use ViewModel getter
                        onChanged: (value) {
                          viewModel.updatePreference('financialSummaryEmails', value); // Save to Firestore
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- HANDLER FUNCTIONS ---

  // NOTE: _showFeedback is defined above the build method

  // --- Helper Methods (Theme-aware fix applied) ---

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

  Widget _buildToggleSetting(BuildContext context, {required String title, required IconData icon, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
      secondary: Icon(icon, color: AppColors.primaryGreen),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryGreen,
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}