import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String? id;
  final String title;
  final String body;
  final String adminUid;
  final String adminName;
  final DateTime createdAt;
  final bool isPinned;

  AnnouncementModel({
    this.id,
    required this.title,
    required this.body,
    required this.adminUid,
    required this.adminName,
    required this.createdAt,
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() => {
    'title': title, 'body': body, 'adminUid': adminUid,
    'adminName': adminName,
    'createdAt': Timestamp.fromDate(createdAt),
    'isPinned': isPinned,
  };

  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String id) =>
      AnnouncementModel(
        id: id,
        title: map['title'] ?? '',
        body: map['body'] ?? '',
        adminUid: map['adminUid'] ?? '',
        adminName: map['adminName'] ?? 'Manager',
        createdAt: map['createdAt'] != null
            ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
        isPinned: map['isPinned'] == true,
      );
}
