// lib/views/shared/placeholder_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppColors {
  static const Color darkGreen = Color(0xFF2E7D32);
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text(title, style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Center(
        child: Text(
          '$title Module is Under Development',
          style: GoogleFonts.roboto(fontSize: 18, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}