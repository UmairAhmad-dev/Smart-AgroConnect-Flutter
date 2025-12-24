// lib/views/home/crop_detail_screen.dart (Final Code with Yield Integration)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Needed for yield icon

import '../../view_models/crop_view_model.dart';
import '../../models/crop_model.dart';
// --- CRITICAL MODULE IMPORTS ---
import '../task/crop_task_list_screen.dart';     // Screen 11: Task List
import '../expense/crop_expense_list_screen.dart'; // Screen 13: Expense List
import '../yield/crop_yield_history_screen.dart';  // NEW: Screen 20: Yield History
// -------------------------------

// Reusing constants
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
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentBlue = Color(0xFF42A5F5); // For expenses
  static const Color accentRed = Color(0xFFD32F2F);  // For delete button
  static const Color accentPurple = Color(0xFF673AB7); // NEW: For Yield button
}

class CropDetailScreen extends StatefulWidget {
  final CropModel crop;

  const CropDetailScreen({super.key, required this.crop});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isEditing = false;
  final List<String> _cropStatuses = ['Active', 'Harvesting', 'Completed', 'Maintenance'];
  final List<String> _cropTypes = ['Wheat', 'Rice', 'Corn', 'Cotton', 'Vegetables', 'Other'];

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  // --- CRUD: UPDATE FUNCTION ---
  Future<void> _handleUpdate() async {
    final viewModel = Provider.of<CropViewModel>(context, listen: false);

    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formValue = _formKey.currentState!.value;

      final updatedCrop = CropModel(
        id: widget.crop.id,
        userId: widget.crop.userId,
        name: formValue['name'],
        type: formValue['type'],
        plantingDate: formValue['planting_date'],
        status: formValue['status'],
        notes: formValue['notes'] ?? '',
        areaAcres: (formValue['area_acres'] is String)
            ? double.tryParse(formValue['area_acres'] as String)!
            : (formValue['area_acres'] as num).toDouble(),
      );

      try {
        await viewModel.updateCrop(updatedCrop);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Crop updated successfully!'), backgroundColor: AppColors.primaryGreen));
        _toggleEditMode(); // Exit edit mode on success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update crop: $e'), backgroundColor: Colors.red));
      }
    }
  }

  // --- CRUD: DELETE FUNCTION ---
  Future<void> _handleDelete() async {
    final viewModel = Provider.of<CropViewModel>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete the record for "${widget.crop.name}"? This cannot be undone.'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await viewModel.deleteCrop(widget.crop.id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Crop deleted successfully!'), backgroundColor: Colors.orange));
        Navigator.of(context).pop(); // Go back to the list screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete crop: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text(_isEditing ? 'Editing ${widget.crop.name}' : 'Crop Details', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          // Edit/Save Button
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
            onPressed: _isEditing ? _handleUpdate : _toggleEditMode,
          ),
          // Delete Button (Visible only when not editing)
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: AppColors.accentRed),
              onPressed: _handleDelete,
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: SizedBox(
            width: 700, // Max width constraint for professional look on web
            child: FormBuilder(
              key: _formKey,
              enabled: _isEditing,
              initialValue: {
                'name': widget.crop.name,
                'type': widget.crop.type,
                'area_acres': widget.crop.areaAcres.toStringAsFixed(2),
                'planting_date': widget.crop.plantingDate,
                'status': widget.crop.status,
                'notes': widget.crop.notes,
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildFormFields(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      // Current Status Display (Highlighted Card)
      Card(
        color: AppColors.primaryGreen.withOpacity(0.1),
        elevation: 0,
        margin: const EdgeInsets.only(bottom: AppSpacing.large),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.darkGreen),
              const SizedBox(width: AppSpacing.medium),
              Text(
                'Current Status: ${widget.crop.status}',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: AppColors.darkGreen),
              ),
            ],
          ),
        ),
      ),

      // --- MANAGEMENT BUTTONS ROW ---
      Row(
        children: [
          // 1. TASK MANAGEMENT BUTTON
          Expanded(
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(right: AppSpacing.small, bottom: AppSpacing.xlarge),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CropTaskListScreen(crop: widget.crop),
                    ),
                  );
                },
                icon: const Icon(Icons.playlist_add_check, color: Colors.white),
                label: Text('Tasks', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),

          // 2. EXPENSE MANAGEMENT BUTTON
          Expanded(
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(left: AppSpacing.small, right: AppSpacing.small, bottom: AppSpacing.xlarge),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CropExpenseListScreen(crop: widget.crop),
                    ),
                  );
                },
                icon: const Icon(Icons.attach_money, color: Colors.white),
                label: Text('Expenses', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),

          // 3. NEW YIELD MANAGEMENT BUTTON (Screen 20 Link)
          Expanded(
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(left: AppSpacing.small, bottom: AppSpacing.xlarge),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CropYieldHistoryScreen(crop: widget.crop),
                    ),
                  );
                },
                icon: const Icon(FontAwesomeIcons.seedling, color: Colors.white),
                label: Text('Yields', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPurple, // Use a distinct color
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
        ],
      ),
      // --- END MANAGEMENT BUTTONS ROW ---

      // Name
      FormBuilderTextField(
        name: 'name',
        readOnly: !_isEditing,
        decoration: InputDecoration(labelText: 'Crop Name', suffixIcon: _isEditing ? null : const Icon(Icons.lock_outline, size: 16)),
        validator: FormBuilderValidators.required(),
      ),
      const SizedBox(height: AppSpacing.medium),

      // Type
      FormBuilderDropdown<String>(
        name: 'type',
        enabled: _isEditing,
        decoration: const InputDecoration(labelText: 'Crop Type'),
        items: _cropTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
        validator: FormBuilderValidators.required(),
      ),
      const SizedBox(height: AppSpacing.medium),

      // Area (Acres)
      FormBuilderTextField(
        name: 'area_acres',
        readOnly: !_isEditing,
        decoration: const InputDecoration(labelText: 'Area (Acres)'),
        keyboardType: TextInputType.number,
        validator: FormBuilderValidators.compose([FormBuilderValidators.required(), FormBuilderValidators.numeric(), FormBuilderValidators.min(0.1)]),
      ),
      const SizedBox(height: AppSpacing.medium),

      // Planting Date
      FormBuilderDateTimePicker(
        name: 'planting_date',
        enabled: _isEditing,
        inputType: InputType.date,
        decoration: const InputDecoration(labelText: 'Planting Date'),
        format: DateFormat.yMMMd(),
        validator: FormBuilderValidators.required(),
      ),
      const SizedBox(height: AppSpacing.medium),

      // Status
      FormBuilderDropdown<String>(
        name: 'status',
        enabled: _isEditing,
        decoration: const InputDecoration(labelText: 'Status'),
        items: _cropStatuses.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
        validator: FormBuilderValidators.required(),
      ),
      const SizedBox(height: AppSpacing.medium),

      // Notes
      FormBuilderTextField(
        name: 'notes',
        readOnly: !_isEditing,
        decoration: const InputDecoration(labelText: 'Notes/Details'),
        maxLines: 3,
      ),
      const SizedBox(height: AppSpacing.medium),

      // Delete Button
      if (!_isEditing)
        Container(
          height: 50,
          margin: const EdgeInsets.only(top: AppSpacing.xlarge),
          child: ElevatedButton.icon(
            onPressed: _handleDelete,
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: const Text('DELETE THIS CROP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ),
        ),
    ];
  }
}