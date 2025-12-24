// lib/views/yield/add_edit_crop_yield_screen.dart (Screen 19: Add/Edit Yield Form)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/crop_model.dart';
import '../../models/crop_yield_model.dart';
import '../../view_models/crop_yield_view_model.dart';

// Reusing constants
abstract class AppSpacing {
  static const double medium = 16.0;
  static const double large = 24.0;
}

abstract class AppColors {
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);
}


class AddEditCropYieldScreen extends StatefulWidget {
  final CropModel crop;
  final CropYieldModel? yieldRecord; // Nullable: If null, we are adding a new record

  const AddEditCropYieldScreen({super.key, required this.crop, this.yieldRecord});

  @override
  State<AddEditCropYieldScreen> createState() => _AddEditCropYieldScreenState();
}

class _AddEditCropYieldScreenState extends State<AddEditCropYieldScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  // Define common yield units
  final List<String> _yieldUnits = [
    'Kilograms (kg)',
    'Metric Tons (T)',
    'Bushels (bu)',
    'Bags',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill form fields if editing an existing record
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.yieldRecord != null) {
        _formKey.currentState?.patchValue({
          'harvestDate': widget.yieldRecord!.harvestDate,
          'quantity': widget.yieldRecord!.quantity.toString(),
          'unit': widget.yieldRecord!.unit,
          'notes': widget.yieldRecord!.notes,
        });
      }
    });
  }

  void _saveForm(CropYieldViewModel viewModel) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final fields = _formKey.currentState!.value;

      final quantity = double.tryParse(fields['quantity'].toString());
      final harvestDate = fields['harvestDate'] as DateTime;

      if (quantity == null) {
        _showFeedback('Invalid quantity entered.', false);
        return;
      }

      // Construct the new or updated yield model
      final newYield = CropYieldModel(
        id: widget.yieldRecord?.id ?? '', // Use existing ID if editing
        cropId: widget.crop.id,
        harvestDate: harvestDate,
        quantity: quantity,
        unit: fields['unit'],
        notes: fields['notes'] ?? '',
      );

      try {
        if (widget.yieldRecord == null) {
          // Adding new record
          await viewModel.addYield(newYield);
          _showFeedback('Yield record created successfully.', true);
        } else {
          // Updating existing record
          await viewModel.updateYield(newYield);
          _showFeedback('Yield record updated successfully.', true);
        }
        Navigator.pop(context); // Go back to the Yield List
      } catch (e) {
        _showFeedback('Error saving yield record: $e', false);
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
    final yieldViewModel = Provider.of<CropYieldViewModel>(context, listen: false);
    final isEditing = widget.yieldRecord != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text(
          isEditing ? 'Edit Yield Record' : 'Log Harvest Yield for ${widget.crop.name}',
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () => _saveForm(yieldViewModel),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 700,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'harvestDate': widget.yieldRecord?.harvestDate ?? DateTime.now(),
                'unit': widget.yieldRecord?.unit ?? _yieldUnits.first,
                'notes': widget.yieldRecord?.notes,
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Harvest Data', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                  Text('Record the final output of the harvest.', style: GoogleFonts.roboto(color: Colors.grey.shade600)),
                  const Divider(height: AppSpacing.large),

                  // 1. Harvest Date Picker
                  FormBuilderDateTimePicker(
                    name: 'harvestDate',
                    inputType: InputType.date,
                    format: DateFormat('MMM d, yyyy'),
                    decoration: const InputDecoration(
                      labelText: 'Harvest Date *',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    lastDate: DateTime.now(), // Cannot log future harvests
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  // 2. Quantity (Numeric Input)
                  FormBuilderTextField(
                    name: 'quantity',
                    decoration: const InputDecoration(
                      labelText: 'Harvest Quantity *',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(errorText: 'Must be a valid number.'),
                      FormBuilderValidators.min(0.01, errorText: 'Quantity must be greater than zero.'),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  // 3. Unit Dropdown
                  FormBuilderDropdown<String>(
                    name: 'unit',
                    decoration: const InputDecoration(
                      labelText: 'Unit of Measure *',
                      hintText: 'Select unit (e.g., Tons)',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    items: _yieldUnits.map((unit) => DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    )).toList(),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: AppSpacing.medium),


                  // 4. Notes (Optional)
                  FormBuilderTextField(
                    name: 'notes',
                    decoration: const InputDecoration(
                      labelText: 'Quality/Notes',
                      prefixIcon: Icon(Icons.notes),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.large),

                  // --- Delete Button (Only visible when editing) ---
                  if (isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        label: Text('Delete Record', style: GoogleFonts.roboto(color: Colors.red)),
                        onPressed: () => _confirmDelete(context, yieldViewModel),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.medium),
                          side: const BorderSide(color: Colors.red),
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

  void _confirmDelete(BuildContext context, CropYieldViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to permanently delete this yield record?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await viewModel.deleteYield(widget.yieldRecord!.id);
              _showFeedback('Yield record deleted.', true);
              // Pop the confirmation dialog, then pop the edit screen
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}