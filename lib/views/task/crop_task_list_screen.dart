// lib/views/task/crop_task_list_screen.dart (Screen 11: Task List)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/crop_model.dart';
import '../../models/crop_task_model.dart';
import '../../view_models/crop_task_view_model.dart';
import 'add_edit_crop_task_screen.dart'; // Screen 12: To be created next

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


class CropTaskListScreen extends StatelessWidget {
  final CropModel crop; // The specific crop to display tasks for

  const CropTaskListScreen({super.key, required this.crop});

  @override
  Widget build(BuildContext context) {
    // Access the Task ViewModel
    final taskViewModel = Provider.of<CropTaskViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: Text('${crop.name} Tasks', style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          // Button to navigate to the Add Task Screen
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () {
              // Navigate to the Add/Edit Task Screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditCropTaskScreen(crop: crop),
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
            child: StreamBuilder<List<CropTaskModel>>(
              // CRITICAL: Filter tasks only for the current crop ID
              stream: taskViewModel.getTasksForCropStream(crop.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading tasks: ${snapshot.error}', style: GoogleFonts.roboto(color: Colors.red)));
                }

                final tasks = snapshot.data ?? [];

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(FontAwesomeIcons.tasks, size: 60, color: AppColors.primaryGreen),
                        const SizedBox(height: AppSpacing.large),
                        Text('No tasks scheduled for ${crop.name}.', style: GoogleFonts.montserrat(fontSize: 18, color: Colors.grey.shade600)),
                        const SizedBox(height: AppSpacing.medium),
                        Text('Tap the "+" icon to add your first task.', style: GoogleFonts.roboto(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }

                // --- Display Task List ---
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _buildTaskListItem(context, task, taskViewModel);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget for a single Task item ---
  Widget _buildTaskListItem(BuildContext context, CropTaskModel task, CropTaskViewModel viewModel) {
    // Determine status colors
    final isOverdue = !task.isCompleted && task.dueDate.isBefore(DateTime.now());
    final statusColor = task.isCompleted ? AppColors.darkGreen : isOverdue ? Colors.red.shade700 : AppColors.accentOrange;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: AppSpacing.medium),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
              color: task.isCompleted ? AppColors.darkGreen.withOpacity(0.5) : Colors.transparent,
              width: 1
          )
      ),
      child: ListTile(
        tileColor: task.isCompleted ? Colors.green.shade50 : Theme.of(context).cardColor,

        // Leading check box for completion
        leading: IconButton(
          icon: Icon(
            task.isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: task.isCompleted ? AppColors.darkGreen : Colors.grey,
            size: 30,
          ),
          onPressed: () => viewModel.toggleTaskCompletion(task),
        ),

        // Title and Description
        title: Text(
          task.title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey.shade500 : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),

        // Subtitle with Task Type and Status
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${task.type}', style: GoogleFonts.roboto(fontSize: 14)),
            Row(
              children: [
                Icon(isOverdue ? Icons.warning : Icons.calendar_today, size: 14, color: statusColor),
                const SizedBox(width: AppSpacing.xsmall),
                Text(
                  task.isCompleted
                      ? 'Completed'
                      : isOverdue
                      ? 'OVERDUE: ${DateFormat('MMM d').format(task.dueDate)}'
                      : 'Due: ${DateFormat('MMM d, yyyy').format(task.dueDate)}',
                  style: GoogleFonts.roboto(fontSize: 14, color: statusColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),

        // Trailing icon for editing
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryGreen),

        onTap: () {
          // Navigate to the Add/Edit Task Screen for editing
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddEditCropTaskScreen(crop: crop, task: task),
            ),
          );
        },
      ),
    );
  }
}