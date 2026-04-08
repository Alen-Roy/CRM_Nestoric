import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of activities that can be logged against a lead or client.
enum ActivityType { call, meeting, email, proposal, note }

extension ActivityTypeExt on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.call:
        return 'Call';
      case ActivityType.meeting:
        return 'Meeting';
      case ActivityType.email:
        return 'Email';
      case ActivityType.proposal:
        return 'Proposal';
      case ActivityType.note:
        return 'Note';
    }
  }

  String get emoji {
    switch (this) {
      case ActivityType.call:
        return '📞';
      case ActivityType.meeting:
        return '🤝';
      case ActivityType.email:
        return '📧';
      case ActivityType.proposal:
        return '📄';
      case ActivityType.note:
        return '📝';
    }
  }

  static ActivityType fromString(String value) {
    switch (value) {
      case 'call':
        return ActivityType.call;
      case 'meeting':
        return ActivityType.meeting;
      case 'email':
        return ActivityType.email;
      case 'proposal':
        return ActivityType.proposal;
      default:
        return ActivityType.note;
    }
  }
}

class ActivityModel {
  final String? id;
  final String leadId;
  final ActivityType type;
  final String? outcome; // e.g. "Interested", "Follow-up needed"
  final String? notes;
  final DateTime createdAt;
  final String createdBy; // userId

  const ActivityModel({
    this.id,
    required this.leadId,
    required this.type,
    this.outcome,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'leadId': leadId,
      'type': type.name,
      'outcome': outcome,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map, String id) {
    return ActivityModel(
      id: id,
      leadId: map['leadId'] ?? '',
      type: ActivityTypeExt.fromString(map['type'] ?? 'note'),
      outcome: map['outcome'],
      notes: map['notes'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: map['createdBy'] ?? '',
    );
  }
}
