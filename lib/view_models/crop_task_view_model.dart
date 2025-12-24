// lib/view_models/crop_task_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/crop_task_model.dart';
import 'auth_view_model.dart'; // To get the current user ID

class CropTaskViewModel with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthViewModel _authViewModel; // Dependency injection for user ID

  CropTaskViewModel(this._authViewModel);

  // Helper to get the base collection path for tasks under the current user
  String get _taskCollectionPath => 'users/${_authViewModel.currentUser!.uid}/tasks';

  // --- Stream for all Tasks (Used for Dashboard) ---
  Stream<List<CropTaskModel>> get allTasksStream {
    if (_authViewModel.currentUser == null) return const Stream.empty();

    // FIX 1: Must match the standard descending order for all list displays
    return _db.collection(_taskCollectionPath)
        .orderBy('dueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CropTaskModel.fromFirestore(doc))
        .toList());
  }

  // --- Stream for Tasks of a Specific Crop (Used for List Screen) ---
  Stream<List<CropTaskModel>> getTasksForCropStream(String cropId) {
    if (_authViewModel.currentUser == null) return const Stream.empty();

    // CRITICAL FIX 2: This query must be DESCENDING to match the required Firebase index.
    return _db.collection(_taskCollectionPath)
        .where('cropId', isEqualTo: cropId)
        .orderBy('dueDate', descending: true) // FIXED to match Firebase index (cropId ASC, dueDate DESC)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CropTaskModel.fromFirestore(doc))
        .toList());
  }

  // --- NEW: Gets count of pending (incomplete) tasks for the Dashboard KPI ---
  Future<int> getPendingTaskCount() async {
    final userId = _authViewModel.currentUser?.uid;
    if (userId == null) return 0;

    // We fetch data directly to get the count of non-completed tasks
    final snapshot = await _db.collection(_taskCollectionPath)
        .where('isCompleted', isEqualTo: false) // Filter by incomplete status
        .get();

    return snapshot.docs.length;
  }

  // --- Create/Add Task ---
  Future<void> addTask(CropTaskModel task) async {
    await _db.collection(_taskCollectionPath).add(task.toMap());
  }

  // --- Update Task ---
  Future<void> updateTask(CropTaskModel task) async {
    await _db.collection(_taskCollectionPath).doc(task.id).update(task.toMap());
  }

  // --- Delete Task ---
  Future<void> deleteTask(String taskId) async {
    await _db.collection(_taskCollectionPath).doc(taskId).delete();
  }

  // --- Toggle Completion Status ---
  Future<void> toggleTaskCompletion(CropTaskModel task) async {
    final newStatus = !task.isCompleted;
    final newCompletedDate = newStatus ? DateTime.now() : null;

    await _db.collection(_taskCollectionPath).doc(task.id).update({
      'isCompleted': newStatus,
      'completedDate': newCompletedDate != null ? Timestamp.fromDate(newCompletedDate) : null,
    });
  }
}