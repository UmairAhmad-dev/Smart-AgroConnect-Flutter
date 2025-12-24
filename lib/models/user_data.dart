// lib/models/user_data.dart

class UserData {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl; // Optional for profile picture

  UserData({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  // Factory constructor to create a UserData object from a Firestore document map
  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      uid: data['uid'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String,
      photoUrl: data['photoUrl'] as String?,
    );
  }

  // Convert the UserData object to a map for writing to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': DateTime.now().toIso8601String(), // Timestamp for registration
    };
  }
}