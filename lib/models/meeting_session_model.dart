import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore collection: `meeting_sessions`
///
/// Lifecycle:
///   salesperson taps "Start Meeting"  → status = 'active'  (lat/lng written)
///   salesperson taps "End Meeting"    → status = 'ended'   (endTime written, lat/lng cleared)
///
/// Admin watches a real-time stream; only 'active' sessions are shown.
class MeetingSessionModel {
  final String? id;
  final String userId;       // salesperson uid
  final String workerName;   // display name
  final String leadId;
  final String leadName;
  final String status;       // 'active' | 'ended'
  final double? lat;
  final double? lng;
  final DateTime startTime;
  final DateTime? endTime;

  const MeetingSessionModel({
    this.id,
    required this.userId,
    required this.workerName,
    required this.leadId,
    required this.leadName,
    required this.status,
    this.lat,
    this.lng,
    required this.startTime,
    this.endTime,
  });

  bool get isActive => status == 'active';

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'workerName': workerName,
        'leadId': leadId,
        'leadName': leadName,
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
        leadId: map['leadId'] ?? '',
        leadName: map['leadName'] ?? '',
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
    String? status,
    double? lat,
    double? lng,
    DateTime? endTime,
  }) =>
      MeetingSessionModel(
        id: id,
        userId: userId,
        workerName: workerName,
        leadId: leadId,
        leadName: leadName,
        status: status ?? this.status,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        startTime: startTime,
        endTime: endTime ?? this.endTime,
      );
}
