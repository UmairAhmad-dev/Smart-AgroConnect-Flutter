// lib/view_models/crop_yield_view_model.dart (Final, Error-Free Code)

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/crop_yield_model.dart';
import 'auth_view_model.dart'; // To get the current user ID

class CropYieldViewModel with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthViewModel _authViewModel;

  CropYieldViewModel(this._authViewModel);

  // Helper to get the base collection path for yield records under the current user
  String get _yieldCollectionPath => 'users/${_authViewModel.currentUser!.uid}/yields';

  // --- Stream for Yield Records of a Specific Crop (Used for List Screen) ---
  Stream<List<CropYieldModel>> getYieldsForCropStream(String cropId) {
    if (_authViewModel.currentUser == null) return const Stream.empty();

    return _db.collection(_yieldCollectionPath)
        .where('cropId', isEqualTo: cropId)
        .orderBy('harvestDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CropYieldModel.fromFirestore(doc))
        .toList());
  }

  // --- Create/Add Yield Record (FIXED: Renamed parameter to yieldRecord) ---
  Future<void> addYield(CropYieldModel yieldRecord) async {
    await _db.collection(_yieldCollectionPath).add(yieldRecord.toMap());
  }

  // --- Update Yield Record (FIXED: Renamed parameter to yieldRecord) ---
  Future<void> updateYield(CropYieldModel yieldRecord) async {
    await _db.collection(_yieldCollectionPath).doc(yieldRecord.id).update(yieldRecord.toMap());
  }

  // --- Delete Yield Record ---
  Future<void> deleteYield(String yieldId) async {
    await _db.collection(_yieldCollectionPath).doc(yieldId).delete();
  }
}