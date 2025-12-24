// lib/views/auth/signup_screen.dart (Card-Based UI)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../view_models/auth_view_model.dart';

// Reuse Spacing and Colors definitions for consistency
// NOTE: These should ideally be in a separate constants file, but are included here for clarity.
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


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers for form inputs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Function to handle the signup attempt (Backend Integration)
  Future<void> _handleSignup() async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    bool success = await viewModel.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      displayName: _nameController.text.trim(),
    );

    if (success) {
      // Success message will show, and AuthWrapper handles navigation to Home
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Signup Failed.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: SizedBox(
          // Constrain the width of the card for readability on wide screens (Web)
          width: 450,
          child: Card(
            elevation: 8.0, // Subtle shadow for the card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.medium),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xlarge),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Essential for Card
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // --- 1. Branding/Title Section ---
                    Image.asset(
                      'lib/assets/images/logo.png', // Reusing the logo asset
                      height: 60,
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      'Register Your Farm',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xlarge),

                    // --- 2. Name Input ---
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name / Farm Name',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.primaryGreen),
                      ),
                      keyboardType: TextInputType.name,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Please enter your name/farm name' : null,
                    ),
                    const SizedBox(height: AppSpacing.medium),

                    // --- 3. Email Input ---
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.primaryGreen),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => (value == null || value.isEmpty || !value.contains('@'))
                          ? 'Please enter a valid email' : null,
                    ),
                    const SizedBox(height: AppSpacing.medium),

                    // --- 4. Password Input ---
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password (min 6 characters)',
                        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primaryGreen),
                      ),
                      obscureText: true,
                      validator: (value) => (value == null || value.length < 6)
                          ? 'Password must be at least 6 characters' : null,
                    ),
                    const SizedBox(height: AppSpacing.medium),

                    // --- 5. Confirm Password Input ---
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock_reset, color: AppColors.primaryGreen),
                      ),
                      obscureText: true,
                      validator: (value) => (value != _passwordController.text)
                          ? 'Passwords do not match' : null,
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // --- 6. Gradient Sign Up Button ---
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryGreen, AppColors.darkGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.5),
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : Text(
                          'CREATE ACCOUNT',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // --- 7. Back to Login Link ---
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Already have an account? Log In",
                        style: GoogleFonts.roboto(
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
}