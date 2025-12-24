// lib/views/home/crop_list_screen.dart (Final Code for Listing and Routing)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../view_models/crop_view_model.dart';
import '../../models/crop_model.dart';
import 'add_crop_screen.dart'; // Route for adding new crops
import 'crop_detail_screen.dart'; // Route for viewing/editing details

// Reusing constants
abstract class AppSpacing {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}

abstract class AppColors {
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
}

class CropListScreen extends StatelessWidget {
  // CRITICAL: Must be const to be used in MainHomeShell and MainDrawer
  const CropListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CropViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text('All Registered Crops', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          // Button to navigate to the Add Crop form
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddCropScreen()));
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 800, // Max width constraint for professional look on desktop
          child: StreamBuilder<List<CropModel>>(
            stream: viewModel.cropsStream, // Live stream from Firestore
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading data: ${snapshot.error}'));
              }

              final crops = snapshot.data ?? [];

              if (crops.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.agriculture, size: 80, color: Colors.grey),
                      const SizedBox(height: AppSpacing.medium),
                      Text('No crops found.', style: GoogleFonts.roboto(fontSize: 18, color: Colors.grey)),
                      const SizedBox(height: AppSpacing.medium),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddCropScreen()));
                        },
                        icon: const Icon(Icons.add_circle, color: Colors.white),
                        label: Text('Add Your First Crop', style: GoogleFonts.montserrat(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                      ),
                    ],
                  ),
                );
              }

              // --- Professional List View ---
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.medium),
                itemCount: crops.length,
                itemBuilder: (context, index) {
                  final crop = crops[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: AppSpacing.small),
                    child: ListTile(
                      leading: const Icon(Icons.eco, color: AppColors.darkGreen),
                      title: Text(crop.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
                      subtitle: Text('Type: ${crop.type} | Area: ${crop.areaAcres.toStringAsFixed(1)} Acres | Planted: ${crop.plantingDate.day}/${crop.plantingDate.month}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          // Status badge styling
                          color: crop.status == 'Active' ? AppColors.primaryGreen.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          crop.status,
                          style: GoogleFonts.roboto(
                            color: crop.status == 'Active' ? AppColors.darkGreen : Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      onTap: () {
                        // --- ROUTING TO DETAIL SCREEN (Update/Delete) ---
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CropDetailScreen(crop: crop),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}