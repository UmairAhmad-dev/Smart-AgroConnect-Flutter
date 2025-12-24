// lib/view_models/crop_view_model.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart'; // Required for FlSpot
import '../models/crop_model.dart';
import 'package:flutter/foundation.dart';

class CropViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to get the base collection path
  String get _cropCollectionPath => 'crops';

  // Stream of all crops for the current user (used by Dashboard List)
  Stream<List<CropModel>> get cropsStream {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection(_cropCollectionPath)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CropModel.fromFirestore(doc))
          .toList();
    });
  }

  // --- NEW: Gets count of active crops for the Dashboard KPI ---
  Future<int> getactiveCropCount() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 0;

    // We fetch data directly to get the latest snapshot without waiting for the stream
    final snapshot = await _firestore
        .collection(_cropCollectionPath)
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'Active') // Filter by active status
        .get();

    return snapshot.docs.length;
  }

  // --- NEW METHOD: Get Total Acres Across ALL Crops for Dashboard KPI ---
  // Fixes the static placeholder value on the dashboard.
  Future<double> getTotalAcres() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 0.0;

    try {
      final snapshot = await _firestore
          .collection(_cropCollectionPath)
          .where('userId', isEqualTo: userId)
          .get();

      double totalAcres = 0.0;
      for (var doc in snapshot.docs) {
        // Safely access and sum the 'areaAcres' field
        // NOTE: Firestore stores doubles as 'num', so we safely cast to double.
        final acres = (doc.data()['areaAcres'] as num?)?.toDouble() ?? 0.0;
        totalAcres += acres;
      }
      return totalAcres;
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching total acres: $e");
      }
      return 0.0;
    }
  }


  // Future method to calculate dashboard summaries (DEPRECATED - Kept for legacy compatibility)
  Future<Map<String, int>> getSummaryData() async {
    final crops = await cropsStream.first;

    int activeCount = crops.where((c) => c.status == 'Active').length;
    int completedCount = crops.where((c) => c.status == 'Harvested').length;

    // Placeholder for tasks:
    int pendingTasks = activeCount * 3;

    return {
      'activeCrops': activeCount,
      'pendingTasks': pendingTasks,
      'completedCrops': completedCount,
    };
  }

  // Future method to calculate data points for the Yield Projection Chart
  Future<List<FlSpot>> getChartData() async {
    final crops = await cropsStream.first;

    // Sort crops by planting date to create a chronological series
    crops.sort((a, b) => a.plantingDate.compareTo(b.plantingDate));

    List<FlSpot> dataPoints = [];
    double x = 1.0;

    for (var crop in crops) {
      // Y-axis is the crop's area (Acres), X-axis is the sequential crop index
      double y = crop.areaAcres;

      dataPoints.add(FlSpot(x, y));
      x += 1;
    }

    if (dataPoints.isEmpty) {
      return [const FlSpot(0, 0)];
    }
    return dataPoints;
  }

  // --- CRUD Operations (Unchanged) ---
  Future<void> addCrop(CropModel crop) async {
    if (_auth.currentUser == null) return;
    await _firestore.collection(_cropCollectionPath).add(crop.toMap());
  }

  Future<void> updateCrop(CropModel crop) async {
    if (_auth.currentUser == null) return;
    await _firestore.collection(_cropCollectionPath).doc(crop.id).update(crop.toMap());
  }

  Future<void> deleteCrop(String cropId) async {
    if (_auth.currentUser == null) return;
    await _firestore.collection(_cropCollectionPath).doc(cropId).delete();
  }
}