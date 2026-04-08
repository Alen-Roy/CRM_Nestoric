import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/lead_model.dart';

/// Client status options shown in ClientPage filter tabs.
class ClientStatus {
  static const String active = 'Active';
  static const String vip = 'VIP';
  static const String inactive = 'Inactive';
  static const String completed = 'Completed';

  static const List<String> all = [active, vip, inactive, completed];
}

class ClientModel {
  final String? id;
  final String leadId; // the original lead this client came from
  final String name;
  final String? companyName;
  final String? contactPerson;
  final String phone;
  final String? email;
  final String? city;
  final String status; // Active / VIP / Inactive / Completed
  final double? monthlyValue; // recurring revenue
  final DateTime? contractRenewal;
  final DateTime joinedDate;
  final String userId;
  final String? assignTo;
  final String? service;
  final String? notes;

  const ClientModel({
    this.id,
    required this.leadId,
    required this.name,
    this.companyName,
    this.contactPerson,
    required this.phone,
    this.email,
    this.city,
    this.status = ClientStatus.active,
    this.monthlyValue,
    this.contractRenewal,
    required this.joinedDate,
    required this.userId,
    this.assignTo,
    this.service,
    this.notes,
  });

  /// Create a ClientModel from a LeadModel when it moves to 'Won'.
  factory ClientModel.fromLead(LeadModel lead) {
    double? monthly;
    if (lead.amount != null && lead.amount!.isNotEmpty) {
      final cleaned =
          lead.amount!.replaceAll(RegExp(r'[₹\$,\s]'), '').trim();
      monthly = double.tryParse(cleaned);
    }

    return ClientModel(
      leadId: lead.id ?? '',
      name: lead.name,
      companyName: lead.companyName,
      contactPerson: lead.contactPerson,
      phone: lead.phone,
      email: lead.email,
      city: lead.city,
      status: ClientStatus.active,
      monthlyValue: monthly,
      joinedDate: DateTime.now(),
      userId: lead.userId,
      assignTo: lead.assignTo,
      service: lead.service,
      notes: lead.notes,
    );
  }

  ClientModel copyWith({
    String? id,
    String? leadId,
    String? name,
    String? companyName,
    String? contactPerson,
    String? phone,
    String? email,
    String? city,
    String? status,
    double? monthlyValue,
    DateTime? contractRenewal,
    DateTime? joinedDate,
    String? userId,
    String? assignTo,
    String? service,
    String? notes,
  }) {
    return ClientModel(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      name: name ?? this.name,
      companyName: companyName ?? this.companyName,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      city: city ?? this.city,
      status: status ?? this.status,
      monthlyValue: monthlyValue ?? this.monthlyValue,
      contractRenewal: contractRenewal ?? this.contractRenewal,
      joinedDate: joinedDate ?? this.joinedDate,
      userId: userId ?? this.userId,
      assignTo: assignTo ?? this.assignTo,
      service: service ?? this.service,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'leadId': leadId,
      'name': name,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'phone': phone,
      'email': email,
      'city': city,
      'status': status,
      'monthlyValue': monthlyValue,
      'contractRenewal': contractRenewal != null
          ? Timestamp.fromDate(contractRenewal!)
          : null,
      'joinedDate': Timestamp.fromDate(joinedDate),
      'userId': userId,
      'assignTo': assignTo,
      'service': service,
      'notes': notes,
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map, String id) {
    return ClientModel(
      id: id,
      leadId: map['leadId'] ?? '',
      name: map['name'] ?? '',
      companyName: map['companyName'],
      contactPerson: map['contactPerson'],
      phone: map['phone'] ?? '',
      email: map['email'],
      city: map['city'],
      status: map['status'] ?? ClientStatus.active,
      monthlyValue: (map['monthlyValue'] as num?)?.toDouble(),
      contractRenewal: map['contractRenewal'] != null
          ? (map['contractRenewal'] as Timestamp).toDate()
          : null,
      joinedDate: map['joinedDate'] != null
          ? (map['joinedDate'] as Timestamp).toDate()
          : DateTime.now(),
      userId: map['userId'] ?? '',
      assignTo: map['assignTo'],
      service: map['service'],
      notes: map['notes'],
    );
  }
}
