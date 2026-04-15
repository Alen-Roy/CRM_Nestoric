import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name;
  final bool isAdmin;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.isAdmin = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'name': name ?? '',
        'isAdmin': isAdmin,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'],
      isAdmin: map['isAdmin'] == true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  UserModel copyWith({String? name, bool? isAdmin}) => UserModel(
        uid: uid,
        email: email,
        name: name ?? this.name,
        isAdmin: isAdmin ?? this.isAdmin,
        createdAt: createdAt,
      );
}
