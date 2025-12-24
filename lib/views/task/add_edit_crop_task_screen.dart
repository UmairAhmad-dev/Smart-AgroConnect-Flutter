// lib/views/task/add_edit_crop_task_screen.dart (Screen 12: Add/Edit Task Form)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/crop_model.dart';
import '../../models/crop_task_model.dart';
import '../../view_models/crop_task_view_model.dart';

// Reusing constants
abstract class AppSpacing {
  static const double xsmall = 4.0;
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
}

abstract class AppColors {
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);
}


class AddEditCropTaskScreen extends StatefulWidget {
  final CropModel crop;
  final CropTaskModel? task; // Nullable: If null, we are adding a new task

  const AddEditCropTaskScreen({super.key, required this.crop, this.task});

  @override
  State<AddEditCropTaskScreen> createState() => _AddEditCropTaskScreenState();
}

class _AddEditCropTaskScreenState extends State<AddEditCropTaskScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  // Define task types for the dropdown
  final List<String> _taskTypes = [
    'Irrigation',
    'Fertilizing',
    'Pest Control',
    'Harvesting Prep',
    'Tillage/Sowing',
    'Other Maintenance',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill form fields if editing an existing task
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.task != null) {
        // FIX: Change 'patch' to the correct method name 'patchValue'
        _formKey.currentState?.patchValue(widget.task!.toMap());
      }
    });
  }

  void _saveForm(CropTaskViewModel viewModel) async {
    // FIX: Add FormBuilderValidators dependency if it's not imported (assuming it is, based on previous context)
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final fields = _formKey.currentState!.value;

      // Convert the date from the form back to DateTime
      final dueDate = fields['dueDate'] as DateTime;

      // Construct the new or updated task model
      final newTask = CropTaskModel(
        id: widget.task?.id ?? '', // Use existing ID if editing
        cropId: widget.crop.id,
        title: fields['title'],
        description: fields['description'] ?? '',
        type: fields['type'],
        dueDate: dueDate,
        isCompleted: widget.task?.isCompleted ?? false,
        completedDate: widget.task?.completedDate,
      );

      try {
        if (widget.task == null) {
          // Adding new task
          await viewModel.addTask(newTask);
          _showFeedback('Task created successfully for ${widget.crop.name}.', true);
        } else {
          // Updating existing task
          await viewModel.updateTask(newTask);
          _showFeedback('Task updated successfully.', true);
        }
        Navigator.pop(context); // Go back to the Task List
      } catch (e) {
        _showFeedback('Error saving task: $e', false);
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
    final taskViewModel = Provider.of<CropTaskViewModel>(context, listen: false);
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text(
          isEditing ? 'Edit Task: ${widget.task!.title}' : 'Add New Task for ${widget.crop.name}',
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () => _saveForm(taskViewModel),
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
              // Initial values are crucial for the FormBuilder Date Picker
              initialValue: {
                'title': widget.task?.title,
                'description': widget.task?.description,
                'type': widget.task?.type,
                'dueDate': widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 7)),
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Task Details', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                  Text('Fields marked * are mandatory.', style: GoogleFonts.roboto(color: Colors.grey.shade600)),
                  const Divider(height: AppSpacing.large),

                  // 1. Task Title
                  FormBuilderTextField(
                    name: 'title',
                    decoration: const InputDecoration(
                      labelText: 'Task Title *',
                      prefixIcon: Icon(Icons.assignment),
                    ),
                    // Assuming FormBuilderValidators is imported correctly
                    validator: (value) => (value == null || value.isEmpty) ? 'Title is required.' : null,
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  // 2. Task Type Dropdown
                  FormBuilderDropdown<String>(
                    name: 'type',
                    decoration: const InputDecoration(
                      labelText: 'Task Type *',
                      hintText: 'Select task category',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _taskTypes.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    )).toList(),
                    validator: (value) => (value == null) ? 'Task type is required.' : null,
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  // 3. Due Date Picker
                  FormBuilderDateTimePicker(
                    name: 'dueDate',
                    inputType: InputType.date,
                    format: DateFormat('MMM d, yyyy'),
                    decoration: const InputDecoration(
                      labelText: 'Due Date *',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    validator: (value) => (value == null) ? 'Due date is required.' : null,
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  // 4. Description (Optional)
                  FormBuilderTextField(
                    name: 'description',
                    decoration: const InputDecoration(
                      labelText: 'Description/Notes',
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
                        label: Text('Delete Task', style: GoogleFonts.roboto(color: Colors.red)),
                        onPressed: () => _confirmDelete(context, taskViewModel),
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

  void _confirmDelete(BuildContext context, CropTaskViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to permanently delete this task?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await viewModel.deleteTask(widget.task!.id);
              _showFeedback('Task deleted.', true);
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