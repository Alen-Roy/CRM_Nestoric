import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ActivityType { call, meeting, email, proposal, note }

extension ActivityTypeExt on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.call:     return 'Call';
      case ActivityType.meeting:  return 'Meeting';
      case ActivityType.email:    return 'Email';
      case ActivityType.proposal: return 'Proposal';
      case ActivityType.note:     return 'Note';
    }
  }

  IconData get icon {
    switch (this) {
      case ActivityType.call:     return Icons.call_rounded;
      case ActivityType.meeting:  return Icons.handshake_rounded;
      case ActivityType.email:    return Icons.mail_rounded;
      case ActivityType.proposal: return Icons.description_rounded;
      case ActivityType.note:     return Icons.edit_note_rounded;
    }
  }

  static ActivityType fromString(String value) {
    switch (value) {
      case 'call':     return ActivityType.call;
      case 'meeting':  return ActivityType.meeting;
      case 'email':    return ActivityType.email;
      case 'proposal': return ActivityType.proposal;
      default:         return ActivityType.note;
    }
  }
}

class ActivityModel {
  final String? id;
  final String leadId;
  final ActivityType type;
  final String? outcome;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  const ActivityModel({
    this.id, required this.leadId, required this.type,
    this.outcome, this.notes, required this.createdAt, required this.createdBy,
  });

  Map<String, dynamic> toMap() => {
    'leadId': leadId, 'type': type.name, 'outcome': outcome,
    'notes': notes, 'createdAt': Timestamp.fromDate(createdAt), 'createdBy': createdBy,
  };

  factory ActivityModel.fromMap(Map<String, dynamic> map, String id) => ActivityModel(
    id: id, leadId: map['leadId'] ?? '',
    type: ActivityTypeExt.fromString(map['type'] ?? 'note'),
    outcome: map['outcome'], notes: map['notes'],
    createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
    createdBy: map['createdBy'] ?? '',
  );
}
