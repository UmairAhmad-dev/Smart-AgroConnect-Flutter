// lib/models/crop_yield_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CropYieldModel {
  final String id;
  final String cropId; // Links yield record to the parent crop
  final DateTime harvestDate;
  final double quantity; // e.g., kg, metric tons, bushels
  final String unit; // e.g., 'kg', 'tons', 'bushels'
  final String notes;

  CropYieldModel({
    required this.id,
    required this.cropId,
    required this.harvestDate,
    required this.quantity,
    required this.unit,
    this.notes = '',
  });

  // Factory constructor for creating a CropYieldModel from a Firestore Document
  factory CropYieldModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data is null for yield ID: ${doc.id}");
    }

    final dateTimestamp = data['harvestDate'] as Timestamp?;

    return CropYieldModel(
      id: doc.id,
      cropId: data['cropId'] as String,
      harvestDate: dateTimestamp?.toDate() ?? DateTime.now(),
      quantity: (data['quantity'] as num).toDouble(), // Safely cast num to double
      unit: data['unit'] as String,
      notes: data['notes'] as String,
    );
  }

  // Convert CropYieldModel instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'cropId': cropId,
      'harvestDate': Timestamp.fromDate(harvestDate),
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}