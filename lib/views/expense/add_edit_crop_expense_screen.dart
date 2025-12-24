// lib/views/expense/add_edit_crop_expense_screen.dart (Screen 14: Add/Edit Expense Form)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/crop_model.dart';
import '../../models/crop_expense_model.dart';
import '../../view_models/crop_expense_view_model.dart';

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


class AddEditCropExpenseScreen extends StatefulWidget {
  final CropModel crop;
  final CropExpenseModel? expense; // Nullable: If null, we are adding a new expense

  const AddEditCropExpenseScreen({super.key, required this.crop, this.expense});

  @override
  State<AddEditCropExpenseScreen> createState() => _AddEditCropExpenseScreenState();
}

class _AddEditCropExpenseScreenState extends State<AddEditCropExpenseScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  // Define common expense categories
  final List<String> _expenseCategories = [
    'Seeds/Planting',
    'Fertilizer/Chemicals',
    'Irrigation/Water',
    'Fuel/Energy',
    'Labor Costs',
    'Maintenance/Repairs',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill form fields if editing an existing expense
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.expense != null) {
        // Use patchValue for flutter_form_builder to set initial values
        _formKey.currentState?.patchValue(widget.expense!.toMap());
      }
    });
  }

  void _saveForm(CropExpenseViewModel viewModel) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final fields = _formKey.currentState!.value;

      final amount = double.tryParse(fields['amount'].toString());
      final date = fields['date'] as DateTime;

      if (amount == null) {
        _showFeedback('Invalid amount entered.', false);
        return;
      }

      final newExpense = CropExpenseModel(
        id: widget.expense?.id ?? '', // Use existing ID if editing
        cropId: widget.crop.id,
        description: fields['description'],
        category: fields['category'],
        amount: amount,
        date: date,
      );

      try {
        if (widget.expense == null) {
          await viewModel.addExpense(newExpense);
          _showFeedback('Expense logged successfully for \$${amount.toStringAsFixed(2)}.', true);
        } else {
          await viewModel.updateExpense(newExpense);
          _showFeedback('Expense updated successfully.', true);
        }
        Navigator.pop(context); // Go back to the Expense List
      } catch (e) {
        _showFeedback('Error saving expense: $e', false);
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
    final expenseViewModel = Provider.of<CropExpenseViewModel>(context, listen: false);
    final isEditing = widget.expense != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text(
          isEditing ? 'Edit Expense' : 'Log New Expense for ${widget.crop.name}',
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () => _saveForm(expenseViewModel),
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
                'description': widget.expense?.description,
                'category': widget.expense?.category,
                'amount': widget.expense?.amount.toStringAsFixed(2),
                'date': widget.expense?.date ?? DateTime.now(),
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Financial Record', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                  Text('Track all costs associated with this crop.', style: GoogleFonts.roboto(color: Colors.grey.shade600)),
                  const Divider(height: AppSpacing.large),

                  // 1. Expense Description
                  FormBuilderTextField(
                    name: 'description',
                    decoration: const InputDecoration(
                      labelText: 'Item Description *',
                      prefixIcon: Icon(Icons.description),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  // 2. Expense Category Dropdown
                  FormBuilderDropdown<String>(
                    name: 'category',
                    decoration: const InputDecoration(
                      labelText: 'Expense Category *',
                      hintText: 'Select category',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _expenseCategories.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    )).toList(),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  // 3. Amount (Currency Input)
                  FormBuilderTextField(
                    name: 'amount',
                    decoration: const InputDecoration(
                      labelText: 'Amount (\$)*',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(errorText: 'Must be a valid number.'),
                      FormBuilderValidators.min(0.01, errorText: 'Amount must be greater than zero.'),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  // 4. Date Picker
                  FormBuilderDateTimePicker(
                    name: 'date',
                    inputType: InputType.date,
                    format: DateFormat('MMM d, yyyy'),
                    decoration: const InputDecoration(
                      labelText: 'Date of Expense *',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: AppSpacing.large),

                  // --- Delete Button (Only visible when editing) ---
                  if (isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        label: Text('Delete Expense', style: GoogleFonts.roboto(color: Colors.red)),
                        onPressed: () => _confirmDelete(context, expenseViewModel),
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

  void _confirmDelete(BuildContext context, CropExpenseViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to permanently delete this expense record?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await viewModel.deleteExpense(widget.expense!.id);
              _showFeedback('Expense deleted.', true);
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