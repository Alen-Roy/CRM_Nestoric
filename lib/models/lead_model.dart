import 'package:cloud_firestore/cloud_firestore.dart';

class LeadModel {
  final String? id;
  final String name;
  final String? companyName;
  final String? contactPerson;
  final String? city;
  final String? email;
  final String phone;
  final String stage;
  final String? lastContacted;
  final String? notes;
  final String? amount;
  final String? service;
  final String? assignTo;
  final String? leadSource;
  final String? priority;
  final DateTime? createdAt;
  final String userId;

  LeadModel({
    this.id,
    required this.name,
    this.companyName,
    this.contactPerson,
    this.city,
    this.email,
    required this.phone,
    required this.stage,
    this.lastContacted,
    this.notes,
    this.amount,
    this.service,
    this.assignTo,
    this.leadSource,
    this.priority,
    this.createdAt,
    required this.userId,
  });

  // ── copyWith: creates a modified copy of this lead ──────────────────────
  // Used when moving stages: lead.copyWith(stage: 'Won')
  // Used when updating notes: lead.copyWith(notes: newText)
  LeadModel copyWith({
    String? id,
    String? name,
    String? companyName,
    String? contactPerson,
    String? city,
    String? email,
    String? phone,
    String? stage,
    String? lastContacted,
    String? notes,
    String? amount,
    String? service,
    String? assignTo,
    String? leadSource,
    String? priority,
    DateTime? createdAt,
    String? userId,
  }) {
    return LeadModel(
      id: id ?? this.id,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      contactPerson: contactPerson ?? this.contactPerson,
      city: city ?? this.city,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      stage: stage ?? this.stage,
      lastContacted: lastContacted ?? this.lastContacted,
      notes: notes ?? this.notes,
      amount: amount ?? this.amount,
      service: service ?? this.service,
      assignTo: assignTo ?? this.assignTo,
      leadSource: leadSource ?? this.leadSource,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'city': city,
      'email': email,
      'phone': phone,
      'stage': stage,
      'lastContacted': lastContacted,
      'notes': notes,
      'amount': amount,
      'service': service,
      'assignTo': assignTo,
      'leadSource': leadSource,
      'priority': priority,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'userId': userId,
    };
  }

  factory LeadModel.fromMap(Map<String, dynamic> map, String id) {
    return LeadModel(
      id: id,
      name: map['name'] ?? '',
      companyName: map['companyName'],
      contactPerson: map['contactPerson'],
      city: map['city'],
      email: map['email'],
      phone: map['phone'] ?? '',
      stage: map['stage'] ?? 'New',
      lastContacted: map['lastContacted'],
      notes: map['notes'],
      amount: map['amount']?.toString(),
      service: map['service'],
      assignTo: map['assignTo'],
      leadSource: map['leadSource'],
      priority: map['priority'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      userId: map['userId'] ?? '',
    );
  }
}
