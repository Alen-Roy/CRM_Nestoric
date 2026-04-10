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
  final String? lastContacted;       // human-readable display string e.g. "8 Apr 2026"
  final DateTime? lastContactedAt;   // machine-readable DateTime — used for follow-up reminders
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
    this.lastContactedAt,
    this.notes,
    this.amount,
    this.service,
    this.assignTo,
    this.leadSource,
    this.priority,
    this.createdAt,
    required this.userId,
  });

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
    DateTime? lastContactedAt,
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
      lastContactedAt: lastContactedAt ?? this.lastContactedAt,
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
      'lastContactedAt': lastContactedAt != null
          ? Timestamp.fromDate(lastContactedAt!)
          : null,
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
    // Parse lastContactedAt — prefer the Timestamp field,
    // fall back to parsing the legacy human-readable string.
    DateTime? lastContactedAt;
    if (map['lastContactedAt'] != null) {
      lastContactedAt = (map['lastContactedAt'] as Timestamp).toDate();
    } else {
      lastContactedAt = _parseDisplayDate(map['lastContacted'] as String?);
    }

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
      lastContactedAt: lastContactedAt,
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

  // Parse "8 Apr 2026" style strings that were stored before lastContactedAt existed.
  static DateTime? _parseDisplayDate(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      const months = {
        'Jan': 1, 'Feb': 2,  'Mar': 3,  'Apr': 4,
        'May': 5, 'Jun': 6,  'Jul': 7,  'Aug': 8,
        'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };
      final parts = s.split(' ');
      if (parts.length == 3) {
        final day   = int.tryParse(parts[0]);
        final month = months[parts[1]];
        final year  = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }
    } catch (_) {}
    return null;
  }
}
