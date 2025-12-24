import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../view_models/crop_view_model.dart';
import '../../models/crop_model.dart';

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
}

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<String> _cropTypes = ['Wheat', 'Rice', 'Corn', 'Cotton', 'Vegetables', 'Other'];

  Future<void> _submitForm(CropViewModel viewModel) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formValue = _formKey.currentState!.value;

      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in.'), backgroundColor: Colors.red));
        return;
      }

      final newCrop = CropModel(
        // ID is placeholder; Firestore will assign the real ID in the ViewModel
        id: '',
        userId: user.uid,
        name: formValue['name'],
        type: formValue['type'],
        plantingDate: formValue['planting_date'],
        status: 'Active',
        notes: formValue['notes'] ?? '',
        areaAcres: (formValue['area_acres'] as num).toDouble(),
      );

      try {
        await viewModel.addCrop(newCrop);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Crop registered successfully!'), backgroundColor: AppColors.primaryGreen));
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add crop: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CropViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text('Register New Crop', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: SizedBox(
            width: 700, // Max width constraint for professional look on web
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // --- 1. Name Input ---
                  FormBuilderTextField(
                    name: 'name',
                    decoration: const InputDecoration(
                      labelText: 'Crop Name (e.g., Wheat Field 1)',
                      prefixIcon: Icon(Icons.drive_file_rename_outline),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.maxLength(50),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  // --- 2. Type Dropdown ---
                  FormBuilderDropdown<String>(
                    name: 'type',
                    decoration: const InputDecoration(
                      labelText: 'Crop Type',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _cropTypes.map((type) => DropdownMenuItem(
                      alignment: AlignmentDirectional.centerStart,
                      value: type,
                      child: Text(type),
                    )).toList(),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  // --- 3. Area (Acres) Input ---
                  FormBuilderTextField(
                    name: 'area_acres',
                    decoration: InputDecoration(
                      labelText: 'Area (Acres)',
                      prefixIcon: Icon(FontAwesomeIcons.mountain),
                    ),
                    keyboardType: TextInputType.number,
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.min(0.1),
                    ]),
                    valueTransformer: (text) => double.tryParse(text ?? ''),
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  // --- 4. Planting Date Picker ---
                  FormBuilderDateTimePicker(
                    name: 'planting_date',
                    initialDate: DateTime.now(),
                    inputType: InputType.date,
                    decoration: const InputDecoration(
                      labelText: 'Planting Date',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  // --- 5. Notes ---
                  FormBuilderTextField(
                    name: 'notes',
                    decoration: const InputDecoration(
                      labelText: 'Notes/Details (Optional)',
                      prefixIcon: Icon(Icons.notes),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.xlarge),

                  // --- 6. Submit Button (Gradient) ---
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
                    child: ElevatedButton.icon(
                      onPressed: () => _submitForm(viewModel),
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        'SAVE CROP RECORD',
                        style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
}