import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String? id;
  final String title;
  final String? notes;
  final DateTime scheduledAt;
  final String priority; // High / Medium / Low
  final String? leadId;
  final String userId;       // owner / creator
  final String? assignedTo;  // worker uid — set when admin assigns
  final bool isAdminTask;    // true when created by admin for a worker
  final String? adminNote;   // optional note from admin with the assignment
  bool isDone;

  TaskModel({
    this.id,
    required this.title,
    this.notes,
    required this.scheduledAt,
    this.priority = 'Medium',
    this.leadId,
    required this.userId,
    this.assignedTo,
    this.isAdminTask = false,
    this.adminNote,
    this.isDone = false,
  });

  TaskModel copyWith({
    String? id, String? title, String? notes, DateTime? scheduledAt,
    String? priority, String? leadId, String? userId,
    String? assignedTo, bool? isAdminTask, String? adminNote, bool? isDone,
  }) => TaskModel(
    id: id ?? this.id, title: title ?? this.title, notes: notes ?? this.notes,
    scheduledAt: scheduledAt ?? this.scheduledAt, priority: priority ?? this.priority,
    leadId: leadId ?? this.leadId, userId: userId ?? this.userId,
    assignedTo: assignedTo ?? this.assignedTo,
    isAdminTask: isAdminTask ?? this.isAdminTask,
    adminNote: adminNote ?? this.adminNote,
    isDone: isDone ?? this.isDone,
  );

  Map<String, dynamic> toMap() => {
    'title': title, 'notes': notes,
    'scheduledAt': Timestamp.fromDate(scheduledAt),
    'priority': priority, 'leadId': leadId, 'userId': userId,
    'assignedTo': assignedTo, 'isAdminTask': isAdminTask,
    'adminNote': adminNote, 'isDone': isDone,
  };

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) => TaskModel(
    id: id,
    title: map['title'] ?? '',
    notes: map['notes'],
    scheduledAt: map['scheduledAt'] != null
        ? (map['scheduledAt'] as Timestamp).toDate() : DateTime.now(),
    priority: map['priority'] ?? 'Medium',
    leadId: map['leadId'],
    userId: map['userId'] ?? '',
    assignedTo: map['assignedTo'],
    isAdminTask: map['isAdminTask'] == true,
    adminNote: map['adminNote'],
    isDone: map['isDone'] ?? false,
  );
}
