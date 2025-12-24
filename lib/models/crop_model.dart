// lib/models/crop_model.dart (CORRECT CONTENT)

import 'package:cloud_firestore/cloud_firestore.dart';

class CropModel {
  final String id;
  final String userId;
  final String name;
  final String type;
  final DateTime plantingDate;
  final String status;
  final String notes;
  final double areaAcres;

  CropModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.plantingDate,
    required this.status,
    required this.notes,
    required this.areaAcres,
  });

  factory CropModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Timestamp plantingTimestamp = data['plantingDate'] as Timestamp;

    return CropModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? 'Untitled Crop',
      type: data['type'] ?? 'Unknown',
      plantingDate: plantingTimestamp.toDate(),
      status: data['status'] ?? 'Active',
      notes: data['notes'] ?? '',
      areaAcres: (data['areaAcres'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type,
      'plantingDate': Timestamp.fromDate(plantingDate),
      'status': status,
      'notes': notes,
      'areaAcres': areaAcres,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}