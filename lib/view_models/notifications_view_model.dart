// lib/view_models/notifications_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_view_model.dart'; // To get the current user ID

class NotificationsViewModel with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthViewModel _authViewModel;

  // --- State for Notification Preferences ---
  Map<String, bool> _preferences = {
    'taskOverdueAlerts': true,
    'weatherAlertsEnabled': true,
    'financialSummaryEmails': false,
    'allowPushNotifications': true,
  };

  Map<String, bool> get preferences => _preferences;

  // Getters for individual settings (easier for the UI)
  bool get taskOverdueAlerts => _preferences['taskOverdueAlerts']!;
  bool get weatherAlertsEnabled => _preferences['weatherAlertsEnabled']!;
  bool get financialSummaryEmails => _preferences['financialSummaryEmails']!;
  bool get allowPushNotifications => _preferences['allowPushNotifications']!;

  NotificationsViewModel(this._authViewModel) {
    // Load preferences immediately upon initialization
    _loadPreferences();
  }

  // --- Firestore Path Helper ---
  String get _settingsDocPath => 'users/${_authViewModel.currentUser!.uid}/settings/notifications';

  // --- Load Preferences from Firestore ---
  Future<void> _loadPreferences() async {
    if (_authViewModel.currentUser == null) return;

    try {
      final doc = await _db.doc(_settingsDocPath).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;

        // Update local state with saved preferences, handling potential nulls
        _preferences = {
          'taskOverdueAlerts': data['taskOverdueAlerts'] ?? true,
          'weatherAlertsEnabled': data['weatherAlertsEnabled'] ?? true,
          'financialSummaryEmails': data['financialSummaryEmails'] ?? false,
          'allowPushNotifications': data['allowPushNotifications'] ?? true,
        };
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading notification preferences: $e");
      }
    }
  }

  // --- Save Individual Preference to Firestore ---
  Future<void> updatePreference(String key, bool value) async {
    if (_authViewModel.currentUser == null) return;

    _preferences[key] = value;
    notifyListeners(); // Update UI optimistically

    try {
      // Use set(merge: true) to only update the specific field
      await _db.doc(_settingsDocPath).set({key: value}, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print("Error saving preference $key: $e");
      }
      // Revert state if saving fails (pessimistic update fallback)
      _preferences[key] = !value;
      notifyListeners();
    }
  }
}