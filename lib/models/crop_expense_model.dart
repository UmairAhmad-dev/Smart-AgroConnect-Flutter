// lib/models/crop_expense_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CropExpenseModel {
  final String id;
  final String cropId; // Links expense to the parent crop
  final String description;
  final String category; // e.g., 'Seed', 'Fertilizer', 'Fuel', 'Labor'
  final double amount; // Expense amount
  final DateTime date;

  CropExpenseModel({
    required this.id,
    required this.cropId,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
  });

  // Factory constructor for creating a CropExpenseModel from a Firestore Document
  factory CropExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data is null for expense ID: ${doc.id}");
    }

    final dateTimestamp = data['date'] as Timestamp?;

    return CropExpenseModel(
      id: doc.id,
      cropId: data['cropId'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      amount: (data['amount'] as num).toDouble(), // Safely cast num to double
      date: dateTimestamp?.toDate() ?? DateTime.now(), // Fallback
    );
  }

  // Convert CropExpenseModel instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'cropId': cropId,
      'description': description,
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(), // For auditing
    };
  }
}