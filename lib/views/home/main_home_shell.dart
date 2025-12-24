// lib/views/home/main_home_shell.dart (Final Structure)

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// --- FINAL MODULE IMPORTS ---
import 'home_dashboard_screen.dart'; // Screen 5: Dashboard
import 'crop_list_screen.dart';     // Screen 6: Crop List
import 'market_analysis_screen.dart'; // Placeholder (Now used as the Financial Hub replacement)
import 'weather_forecast_screen.dart'; // Screen 10: Weather


// Reusing constants
abstract class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
}


class MainHomeShell extends StatefulWidget {
  const MainHomeShell({super.key});

  @override
  State<MainHomeShell> createState() => _MainHomeShellState();
}

class _MainHomeShellState extends State<MainHomeShell> {
  int _selectedIndex = 0;

  // List of screens for the Bottom Navigation Bar (All pointing to functional modules)
  final List<Widget> _screens = [
    const HomeDashboardScreen(),
    const CropListScreen(),
    // NOTE: MarketAnalysisScreen is kept here as a placeholder link for the 3rd tab slot
    const MarketAnalysisScreen(),
    const WeatherForecastScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ensure the default theme is used for the body background
    return Scaffold(
      body: _screens[_selectedIndex],

      // --- Professional Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.pagelines),
            label: 'Crops',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.chartLine),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_queue),
            label: 'Weather',
          ),
        ],
        currentIndex: _selectedIndex,
        // Ensure colors are theme-aware for contrast
        selectedItemColor: AppColors.darkGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}