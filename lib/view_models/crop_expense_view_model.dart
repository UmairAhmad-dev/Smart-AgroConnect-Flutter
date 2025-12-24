// lib/view_models/crop_expense_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/crop_expense_model.dart';
import 'auth_view_model.dart'; // Dependency injection for user ID

class CropExpenseViewModel with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthViewModel _authViewModel; // Dependency injection for user ID

  CropExpenseViewModel(this._authViewModel);

  // Helper to get the base collection path for expenses under the current user
  String get _expenseCollectionPath => 'users/${_authViewModel.currentUser!.uid}/expenses';

  // --- Stream for Expenses of a Specific Crop (Used for List Screen) ---
  Stream<List<CropExpenseModel>> getExpensesForCropStream(String cropId) {
    if (_authViewModel.currentUser == null) return const Stream.empty();

    // NOTE: This query will require a composite index on (cropId, date, descending)
    return _db.collection(_expenseCollectionPath)
        .where('cropId', isEqualTo: cropId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CropExpenseModel.fromFirestore(doc))
        .toList());
  }

  // --- NEW METHOD: Get Total Expenses Across ALL Crops (Fixes Dashboard KPI) ---
  // Fixes the error: The method 'getTotalExpenses' isn't defined
  Future<double> getTotalExpenses() async {
    if (_authViewModel.currentUser == null) return 0.0;

    try {
      final snapshot = await _db.collection(_expenseCollectionPath).get();

      double total = 0.0;
      for (var doc in snapshot.docs) {
        // Safely access the amount field
        final amount = (doc.data()['amount'] as num?)?.toDouble() ?? 0.0;
        total += amount;
      }
      return total;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching total expenses: $e");
      }
      return 0.0;
    }
  }


  // --- Create/Add Expense ---
  Future<void> addExpense(CropExpenseModel expense) async {
    await _db.collection(_expenseCollectionPath).add(expense.toMap());
  }

  // --- Update Expense ---
  Future<void> updateExpense(CropExpenseModel expense) async {
    await _db.collection(_expenseCollectionPath).doc(expense.id).update(expense.toMap());
  }

  // --- Delete Expense ---
  Future<void> deleteExpense(String expenseId) async {
    await _db.collection(_expenseCollectionPath).doc(expenseId).delete();
  }

  // --- Summary Calculation (Existing method for crop-specific total) ---
  Future<double> getTotalExpensesForCrop(String cropId) async {
    final snapshot = await _db.collection(_expenseCollectionPath)
        .where('cropId', isEqualTo: cropId)
        .get();

    double total = 0.0;
    for (var doc in snapshot.docs) {
      // NOTE: Using doc.data()['amount'] is more efficient than rebuilding the whole model here
      final amount = (doc.data()['amount'] as num?)?.toDouble() ?? 0.0;
      total += amount;
    }
    return total;
  }
}