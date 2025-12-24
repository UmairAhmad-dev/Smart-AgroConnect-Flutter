// lib/views/auth/login_screen.dart (Card-Based UI)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../view_models/auth_view_model.dart';
import 'signup_screen.dart';

// Define Spacing and Colors for consistency (Inherited from previous step)
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


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final viewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (!_formKey.currentState!.validate()) return;

    bool success = await viewModel.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Login Failed.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
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
                    // --- 1. Branding Section (Image Asset) ---
                    Image.asset(
                      'lib/assets/images/logo.png',
                      height: 80, // Slightly smaller icon within the card
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      'Welcome Back to AgroConnect',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 24, // Slightly smaller title within the card
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xlarge),

                    // --- 2. Input Fields ---
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

                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primaryGreen),
                      ),
                      obscureText: true,
                      validator: (value) => (value == null || value.length < 6)
                          ? 'Password must be at least 6 characters' : null,
                    ),
                    const SizedBox(height: AppSpacing.large),

                    // --- 3. Gradient Login Button ---
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
                        onPressed: viewModel.isLoading ? null : _handleLogin,
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
                          'LOG IN',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xlarge),

                    // --- 4. Sign Up Link ---
                    TextButton(
                      onPressed: () {
                        viewModel.errorMessage;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Don't have an account? Sign Up Here",
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