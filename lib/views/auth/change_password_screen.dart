// lib/views/auth/change_password_screen.dart (Screen 15: Change Password)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../view_models/auth_view_model.dart';

// Reusing constants
abstract class AppSpacing {
  static const double medium = 16.0;
  static const double large = 24.0;
}

abstract class AppColors {
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color primaryGreen = Color(0xFF4CAF50);
}


class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _handleChangePassword() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final newPassword = _formKey.currentState!.value['new_password'] as String;

      try {
        await authViewModel.changePassword(newPassword);
        _showFeedback('Password updated successfully. You will be logged out on the next session.', true);
        // Clear the form after success
        _formKey.currentState?.fields['new_password']?.didChange(null);
        _formKey.currentState?.fields['confirm_password']?.didChange(null);

      } catch (e) {
        // NOTE: Firebase password changes often require the user to re-authenticate (log in again)
        // if their current session is too old, which is what the message indicates.
        _showFeedback('Error changing password. Please re-login and try again.', false);
      }
    }
  }

  void _showFeedback(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.darkGreen : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text('Change Password', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Security Settings', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                  Text('You must use a new password of at least 6 characters.', style: GoogleFonts.roboto(color: Colors.grey.shade600)),
                  const Divider(height: AppSpacing.large),

                  // 1. New Password Field
                  FormBuilderTextField(
                    name: 'new_password',
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password *',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.minLength(6, errorText: 'Password must be at least 6 characters.'),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  // 2. Confirm Password Field
                  FormBuilderTextField(
                    name: 'confirm_password',
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password *',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                          (val) {
                        if (val != _formKey.currentState?.fields['new_password']?.value) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      }
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.large),

                  // 3. Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.security, color: Colors.white),
                      label: Text('Update Password', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: _handleChangePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
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