// lib/models/crop_task_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CropTaskModel {
  final String id;
  final String cropId; // Links task to the parent crop
  final String title;
  final String description;
  final String type; // e.g., 'Fertilizing', 'Irrigation', 'Pest Control'
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedDate;

  CropTaskModel({
    required this.id,
    required this.cropId,
    required this.title,
    this.description = '',
    required this.type,
    required this.dueDate,
    this.isCompleted = false,
    this.completedDate,
  });

  // Factory constructor for creating a CropTaskModel from a Firestore Document
  factory CropTaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    // Ensure data exists before accessing fields
    if (data == null) {
      throw Exception("Document data is null for task ID: ${doc.id}");
    }

    // Convert Firestore Timestamp to DateTime
    final dueDateTimestamp = data['dueDate'] as Timestamp?;
    final completedDateTimestamp = data['completedDate'] as Timestamp?;

    return CropTaskModel(
      id: doc.id,
      cropId: data['cropId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      type: data['type'] as String,
      dueDate: dueDateTimestamp?.toDate() ?? DateTime.now(), // Fallback
      isCompleted: data['isCompleted'] as bool,
      completedDate: completedDateTimestamp?.toDate(),
    );
  }

  // Convert CropTaskModel instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'cropId': cropId,
      'title': title,
      'description': description,
      'type': type,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'completedDate': completedDate != null ? Timestamp.fromDate(completedDate!) : null,
      'createdAt': FieldValue.serverTimestamp(), // Always useful for auditing
    };
  }
}