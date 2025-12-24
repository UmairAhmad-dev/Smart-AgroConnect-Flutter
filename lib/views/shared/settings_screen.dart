// lib/views/shared/settings_screen.dart (Final Professional UI)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../view_models/theme_provider.dart';
import '../../services/weather_service.dart';
// --- AUTH & UTILITY IMPORTS ---
import '../auth/change_password_screen.dart'; // Screen 15: Change Password
import 'notifications_settings_screen.dart'; // Screen 16: Notifications Settings
// ------------------------------

abstract class AppColors {
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color primaryGreen = Color(0xFF4CAF50);
}

abstract class AppSpacing {
  static const double medium = 16.0;
  static const double large = 24.0;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- 1. LOCAL STATE FOR SETTINGS ---
  bool _isCloudSyncEnabled = true;
  String _appLanguage = 'English (US)';
  String _defaultLocation = 'Lahore, Pakistan'; // State for location
  final List<String> _languages = ['English (US)', 'Urdu (PK)', 'Spanish (ES)'];
  // ------------------------------------

  @override
  void initState() {
    super.initState();
    _loadLocationSetting();
  }

  void _loadLocationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    const String locationKey = 'default_weather_location';
    final city = prefs.getString(locationKey) ?? 'Lahore';

    setState(() {
      _defaultLocation = '$city, Pakistan';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.darkGreen,
            title: Text('App Settings', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          body: Center(
            child: SizedBox(
              width: 600,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.large),
                children: [
                  // --- Appearance Settings ---
                  _buildSettingsGroup(
                    context,
                    title: 'Appearance',
                    children: [
                      _buildToggleSetting(
                        context,
                        title: 'Dark Mode',
                        icon: Icons.dark_mode_outlined,
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (value) {
                          themeProvider.toggleTheme(value);
                          _showFeedback('Dark Mode ${value ? 'enabled' : 'disabled'}');
                        },
                      ),
                      const Divider(),
                      _buildSimpleSetting(
                        context,
                        title: 'App Language',
                        icon: Icons.language,
                        subtitle: _appLanguage,
                        onTap: () => _handleLanguageChange(context),
                      ),
                      const Divider(), // Added divider for separation
                      // --- NEW: Notifications Link (Screen 16) ---
                      _buildSimpleSetting(
                        context,
                        title: 'Notifications & Alerts',
                        icon: Icons.notifications_none_outlined,
                        subtitle: 'Manage task and weather alerts',
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationsSettingsScreen()));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.large),

                  // --- Data & Privacy Settings ---
                  _buildSettingsGroup(
                    context,
                    title: 'Security & Data',
                    children: [
                      // --- NEW: Change Password Link (Screen 15) ---
                      _buildSimpleSetting(
                        context,
                        title: 'Change Password',
                        icon: Icons.vpn_key_outlined,
                        subtitle: 'Update your security credentials',
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
                        },
                      ),
                      const Divider(),
                      // --- DEFAULT LOCATION SETTING ---
                      _buildSimpleSetting(
                        context,
                        title: 'Default Farm Location',
                        icon: Icons.location_on_outlined,
                        subtitle: _defaultLocation,
                        onTap: () => _handleLocationChange(context),
                      ),
                      const Divider(),
                      // --- FUNCTIONAL CLOUD SYNC TOGGLE ---
                      _buildToggleSetting(
                        context,
                        title: 'Sync via Cloud',
                        icon: Icons.cloud_upload_outlined,
                        value: _isCloudSyncEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isCloudSyncEnabled = value;
                            _showFeedback('Cloud Sync ${value ? 'enabled' : 'disabled'}');
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.large),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- HANDLER FUNCTIONS ---

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleLocationChange(BuildContext context) async {
    final newCity = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Location'),
        content: TextFormField(
          initialValue: _defaultLocation.split(',').first.trim(),
          decoration: const InputDecoration(labelText: 'City Name (e.g., Karachi)'),
          onFieldSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
          TextButton(onPressed: () {
            final text = (context.findAncestorWidgetOfExactType<AlertDialog>()!.content as TextFormField).initialValue;
            Navigator.of(context).pop(text);
          }, child: const Text('Save')),
        ],
      ),
    );

    if (newCity != null && newCity.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      const String locationKey = 'default_weather_location';
      await prefs.setString(locationKey, newCity.trim());

      setState(() {
        _defaultLocation = '$newCity, Pakistan';
      });
      _showFeedback('Default weather location set to $newCity');
    }
  }

  void _handleLanguageChange(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _languages.map((lang) => ListTile(
              title: Text(lang),
              trailing: lang == _appLanguage ? const Icon(Icons.check, color: AppColors.primaryGreen) : null,
              onTap: () {
                setState(() => _appLanguage = lang);
                Navigator.pop(context);
                _showFeedback('Language set to $lang');
              },
            )).toList(),
          ),
        );
      },
    );
  }

  // Helper to group settings (Theme-aware fix applied)
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

  // Helper for toggle switch settings (Theme-aware fix applied)
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

  // Helper for simple text settings (Theme-aware fix applied)
  Widget _buildSimpleSetting(BuildContext context, {required String title, required IconData icon, required String subtitle, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: GoogleFonts.roboto(fontSize: 14)),
      leading: Icon(icon, color: AppColors.primaryGreen),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
      tileColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}