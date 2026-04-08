import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String? id;
  final String title;
  final String? notes;
  final DateTime scheduledAt;
  final String priority; // High / Medium / Low
  final String? leadId; // optional link to a lead
  final String userId;
  bool isDone;

  TaskModel({
    this.id,
    required this.title,
    this.notes,
    required this.scheduledAt,
    this.priority = 'Medium',
    this.leadId,
    required this.userId,
    this.isDone = false,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? notes,
    DateTime? scheduledAt,
    String? priority,
    String? leadId,
    String? userId,
    bool? isDone,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      priority: priority ?? this.priority,
      leadId: leadId ?? this.leadId,
      userId: userId ?? this.userId,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'notes': notes,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'priority': priority,
      'leadId': leadId,
      'userId': userId,
      'isDone': isDone,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      notes: map['notes'],
      scheduledAt: map['scheduledAt'] != null
          ? (map['scheduledAt'] as Timestamp).toDate()
          : DateTime.now(),
      priority: map['priority'] ?? 'Medium',
      leadId: map['leadId'],
      userId: map['userId'] ?? '',
      isDone: map['isDone'] ?? false,
    );
  }
}
