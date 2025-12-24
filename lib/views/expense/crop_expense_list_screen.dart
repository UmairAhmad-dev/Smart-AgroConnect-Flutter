// lib/views/expense/crop_expense_list_screen.dart (Screen 13: Expense List)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/crop_model.dart';
import '../../models/crop_expense_model.dart';
import '../../view_models/crop_expense_view_model.dart';
import 'add_edit_crop_expense_screen.dart';

// Reusing constants
abstract class AppSpacing {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}

// FIX: Define a darker blue constant for the light theme text contrast
abstract class AppColors {
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color accentBlue = Color(0xFF42A5F5); // Blue 400
  static const Color accentBlueDark = Color(0xFF1565C0); // FIX: Define a darker blue (Blue 800 equivalent)
  static const Color textBody = Color(0xFF424242);
}


class CropExpenseListScreen extends StatelessWidget {
  final CropModel crop; // The specific crop to display expenses for

  const CropExpenseListScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    final expenseViewModel = Provider.of<CropExpenseViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text('${crop.name} Expenses', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          // Button to navigate to the Add Expense Screen
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () {
              // Navigate to the Add/Edit Expense Screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditCropExpenseScreen(crop: crop),
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
            child: StreamBuilder<List<CropExpenseModel>>(
              // CRITICAL: Filter expenses only for the current crop ID
              stream: expenseViewModel.getExpensesForCropStream(crop.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                }
                if (snapshot.hasError) {
                  // Display error, which will include the need for a composite index if not created
                  return Center(child: Text('Error loading expenses: ${snapshot.error}', style: GoogleFonts.roboto(color: Colors.red)));
                }

                final expenses = snapshot.data ?? [];

                if (expenses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(FontAwesomeIcons.handHoldingUsd, size: 60, color: AppColors.primaryGreen),
                        const SizedBox(height: AppSpacing.large),
                        Text('No expenses logged for ${crop.name}.', style: GoogleFonts.montserrat(fontSize: 18, color: Colors.grey.shade600)),
                        const SizedBox(height: AppSpacing.medium),
                        Text('Tap the "+" icon to record your first cost.', style: GoogleFonts.roboto(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }

                // --- Display Expense Summary and List ---
                return _buildExpenseSummaryAndList(context, expenses, expenseViewModel);
              },
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget for Summary and List (FIX APPLIED) ---
  Widget _buildExpenseSummaryAndList(BuildContext context, List<CropExpenseModel> expenses, CropExpenseViewModel viewModel) {
    // Calculate total expenses for display
    final total = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary Card
        Card(
          elevation: 5,
          // Theme-aware card background
          color: isDarkMode ? AppColors.accentBlue.withOpacity(0.2) : AppColors.accentBlue.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium),
            child: Text(
              'Total Expenses: \$${total.toStringAsFixed(2)}',
              style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  // FIX: Use the defined accentBlueDark constant for contrast in light mode
                  color: isDarkMode ? AppColors.accentBlue : AppColors.accentBlueDark
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.medium),

        // List View
        Expanded(
          child: ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return _buildExpenseListItem(context, expense, viewModel);
            },
          ),
        ),
      ],
    );
  }

  // --- Widget for a single Expense item ---
  Widget _buildExpenseListItem(BuildContext context, CropExpenseModel expense, CropExpenseViewModel viewModel) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDarkMode ? Colors.white70 : AppColors.textBody;
    final secondaryTextColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppSpacing.small),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        tileColor: Theme.of(context).cardColor, // Ensure tile color is theme aware
        leading: Icon(Icons.receipt, color: AppColors.accentBlue),

        // Title: Description
        title: Text(
          expense.description,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ),
        ),

        // Subtitle: Category
        subtitle: Text(
          'Category: ${expense.category}',
          style: GoogleFonts.roboto(fontSize: 14, color: secondaryTextColor),
        ),

        // Trailing: Amount and Date
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '-\$${expense.amount.toStringAsFixed(2)}',
              style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade400
              ),
            ),
            Text(
              DateFormat('MMM d, yyyy').format(expense.date),
              style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),

        onTap: () {
          // Navigate to the Add/Edit Expense Screen for editing
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditCropExpenseScreen(crop: crop, expense: expense),
            ),
          );
        },
      ),
    );
  }
}