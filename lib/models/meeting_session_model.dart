import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore collection: `meeting_sessions`
///
/// A document is created when a salesperson taps "Start Meeting".
/// When they tap "End Meeting", only `status` and `endTime` change —
/// lat/lng are KEPT so the admin can see the full location history.
///
/// [sourceType] is either 'lead' or 'client' so the history page
/// can display the right label.
class MeetingSessionModel {
  final String? id;
  final String userId;        // salesperson uid
  final String workerName;    // display name
  final String sourceType;    // 'lead' | 'client'
  final String leadId;        // always set
  final String leadName;      // lead / client name
  final String? clientId;     // set only when sourceType == 'client'
  final String status;        // 'active' | 'ended'
  final double? lat;          // GPS at start — PRESERVED after end
  final double? lng;
  final DateTime startTime;
  final DateTime? endTime;

  const MeetingSessionModel({
    this.id,
    required this.userId,
    required this.workerName,
    this.sourceType = 'lead',
    required this.leadId,
    required this.leadName,
    this.clientId,
    required this.status,
    this.lat,
    this.lng,
    required this.startTime,
    this.endTime,
  });

  bool get isActive => status == 'active';

  String get durationLabel {
    if (endTime == null) return 'Ongoing';
    final diff = endTime!.difference(startTime);
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m} min';
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'workerName': workerName,
        'sourceType': sourceType,
        'leadId': leadId,
        'leadName': leadName,
        'clientId': clientId,
        'status': status,
        'lat': lat,
        'lng': lng,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      };

  factory MeetingSessionModel.fromMap(Map<String, dynamic> map, String id) =>
      MeetingSessionModel(
        id: id,
        userId: map['userId'] ?? '',
        workerName: map['workerName'] ?? '',
        sourceType: map['sourceType'] ?? 'lead',
        leadId: map['leadId'] ?? '',
        leadName: map['leadName'] ?? '',
        clientId: map['clientId'],
        status: map['status'] ?? 'ended',
        lat: (map['lat'] as num?)?.toDouble(),
        lng: (map['lng'] as num?)?.toDouble(),
        startTime: map['startTime'] != null
            ? (map['startTime'] as Timestamp).toDate()
            : DateTime.now(),
        endTime: map['endTime'] != null
            ? (map['endTime'] as Timestamp).toDate()
            : null,
      );

  MeetingSessionModel copyWith({
    String? id,
    String? status,
    double? lat,
    double? lng,
    DateTime? endTime,
  }) =>
      MeetingSessionModel(
        id: id ?? this.id,
        userId: userId,
        workerName: workerName,
        sourceType: sourceType,
        leadId: leadId,
        leadName: leadName,
        clientId: clientId,
        status: status ?? this.status,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        startTime: startTime,
        endTime: endTime ?? this.endTime,
      );
}
