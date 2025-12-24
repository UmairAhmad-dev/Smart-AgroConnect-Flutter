// lib/views/yield/crop_yield_history_screen.dart (Screen 20: Yield List)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/crop_model.dart';
import '../../models/crop_yield_model.dart';
import '../../view_models/crop_yield_view_model.dart';
import 'add_edit_crop_yield_screen.dart';

// Reusing constants
abstract class AppSpacing {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}

abstract class AppColors {
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color accentBlue = Color(0xFF42A5F5); // For visibility
  static const Color textBody = Color(0xFF424242);
}


class CropYieldHistoryScreen extends StatelessWidget {
  final CropModel crop; // The specific crop to display yields for

  const CropYieldHistoryScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final yieldViewModel = Provider.of<CropYieldViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text('${crop.name} Yield History', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          // Button to navigate to the Add Yield Screen
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () {
              // Navigate to the Add/Edit Yield Screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditCropYieldScreen(crop: crop),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 800, // Max width constraint
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: StreamBuilder<List<CropYieldModel>>(
              // CRITICAL: Filter yields only for the current crop ID
              stream: yieldViewModel.getYieldsForCropStream(crop.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                }
                if (snapshot.hasError) {
                  // This is where an index error would show up, guiding the user to the fix
                  return Center(child: Text('Error loading yield data: ${snapshot.error}', style: GoogleFonts.roboto(color: Colors.red)));
                }

                final yieldRecords = snapshot.data ?? [];

                if (yieldRecords.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(FontAwesomeIcons.wheatAwn, size: 60, color: AppColors.primaryGreen),
                        const SizedBox(height: AppSpacing.large),
                        Text('No harvest records found for ${crop.name}.', style: GoogleFonts.montserrat(fontSize: 18, color: Colors.grey.shade600)),
                        const SizedBox(height: AppSpacing.medium),
                        Text('Tap the "+" icon to log your first harvest.', style: GoogleFonts.roboto(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }

                // --- Display Yield Summary and List ---
                return _buildYieldSummaryAndList(context, yieldRecords, yieldViewModel);
              },
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget for Summary and List ---
  Widget _buildYieldSummaryAndList(BuildContext context, List<CropYieldModel> yieldRecords, CropYieldViewModel viewModel) {
    // Calculate total yield quantity (if units are the same)
    // We assume the dominant unit is the same for simplicity in summary
    final totalQuantity = yieldRecords.fold(0.0, (sum, item) => sum + item.quantity);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary Card
        Card(
          elevation: 5,
          color: isDarkMode ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.primaryGreen.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Text(
              'Total Quantity Logged: ${totalQuantity.toStringAsFixed(2)} ${yieldRecords.first.unit.split(' ').first}',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),

        // List View
        Expanded(
          child: ListView.builder(
            itemCount: yieldRecords.length,
            itemBuilder: (context, index) {
              final record = yieldRecords[index];
              return _buildYieldListItem(context, record, viewModel);
            },
          ),
        ),
      ],
    );
  }

  // --- Widget for a single Yield item ---
  Widget _buildYieldListItem(BuildContext context, CropYieldModel record, CropYieldViewModel viewModel) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? Colors.white70 : AppColors.textBody;
    final secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        tileColor: Theme.of(context).cardColor,
        leading: Icon(FontAwesomeIcons.seedling, color: AppColors.darkGreen),

        // Title: Quantity and Unit
        title: Text(
          '${record.quantity.toStringAsFixed(2)} ${record.unit}',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ),
        ),

        // Subtitle: Harvest Date and Notes preview
        subtitle: Text(
          'Harvested: ${DateFormat('MMM d, yyyy').format(record.harvestDate)}'
              '${record.notes.isNotEmpty ? ' | Notes: ${record.notes}' : ''}',
          style: GoogleFonts.roboto(fontSize: 14, color: secondaryTextColor),
          overflow: TextOverflow.ellipsis,
        ),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),

        onTap: () {
          // Navigate to the Add/Edit Yield Screen for editing
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditCropYieldScreen(crop: crop, yieldRecord: record),
            ),
          );
        },
      ),
    );
  }
}