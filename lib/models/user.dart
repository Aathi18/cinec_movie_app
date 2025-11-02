import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final Timestamp? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.createdAt,
  });

  // Factory method to create a UserModel object from a Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: data['uid'] as String,
      email: data['email'] as String,
      fullName: data['fullName'] as String,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  // Convert the UserModel object into a Map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}