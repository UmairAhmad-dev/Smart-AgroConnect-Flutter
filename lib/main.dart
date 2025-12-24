// lib/main.dart (Final, Integrated with ALL ViewModels and Theme)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import all necessary ViewModels
import 'view_models/auth_view_model.dart';
import 'view_models/crop_view_model.dart';
import 'view_models/theme_provider.dart';
import 'view_models/crop_task_view_model.dart';
import 'view_models/crop_expense_view_model.dart';
import 'view_models/notifications_view_model.dart';
import 'view_models/crop_yield_view_model.dart'; // REQUIRED: Add Crop Yield ViewModel

import 'views/auth/auth_wrapper.dart';
import 'firebase_options.dart';
import 'views/splash_screen.dart';

// Reusing constants (Define these here for global access)
abstract class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the entire app with MultiProvider for all ViewModels
    return MultiProvider(
      providers: [
        // 1. Core ViewModels
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CropViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // 4. CropTaskViewModel
        ChangeNotifierProxyProvider<AuthViewModel, CropTaskViewModel>(
          create: (context) => CropTaskViewModel(Provider.of<AuthViewModel>(context, listen: false)),
          update: (context, auth, previousTasks) => CropTaskViewModel(auth),
        ),

        // 5. CropExpenseViewModel
        ChangeNotifierProxyProvider<AuthViewModel, CropExpenseViewModel>(
          create: (context) => CropExpenseViewModel(Provider.of<AuthViewModel>(context, listen: false)),
          update: (context, auth, previousExpenses) => CropExpenseViewModel(auth),
        ),

        // 6. NotificationsViewModel
        ChangeNotifierProxyProvider<AuthViewModel, NotificationsViewModel>(
          create: (context) => NotificationsViewModel(Provider.of<AuthViewModel>(context, listen: false)),
          update: (context, auth, notifications) => NotificationsViewModel(auth),
        ),

        // 7. FINAL INTEGRATION: CropYieldViewModel
        ChangeNotifierProxyProvider<AuthViewModel, CropYieldViewModel>(
          create: (context) => CropYieldViewModel(Provider.of<AuthViewModel>(context, listen: false)),
          update: (context, auth, previousYields) => CropYieldViewModel(auth),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {

          // --- 1. Define Light Theme ---
          final lightTheme = ThemeData(
            scaffoldBackgroundColor: Colors.white,
            brightness: Brightness.light,
            textTheme: Typography.material2018().black.apply(fontFamily: 'Roboto'),
            appBarTheme: const AppBarTheme(
              color: AppColors.darkGreen,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              labelStyle: const TextStyle(color: AppColors.darkGreen),
            ),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.green,
              brightness: Brightness.light,
            ).copyWith(
              primary: AppColors.primaryGreen,
              secondary: AppColors.darkGreen,
            ),
          );

          // --- 2. Define Dark Theme ---
          final darkTheme = ThemeData(
            scaffoldBackgroundColor: Colors.grey.shade900,
            brightness: Brightness.dark,
            cardColor: Colors.grey.shade800,
            canvasColor: Colors.grey.shade800,

            textTheme: Typography.material2018().white.apply(fontFamily: 'Roboto'),

            appBarTheme: AppBarTheme(
              color: Colors.grey.shade800,
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              labelStyle: const TextStyle(color: AppColors.primaryGreen),
            ),
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.green,
              brightness: Brightness.dark,
            ).copyWith(
              primary: AppColors.primaryGreen,
              secondary: AppColors.primaryGreen,
            ),
          );

          return MaterialApp(
            title: 'Smart AgroConnect',
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}