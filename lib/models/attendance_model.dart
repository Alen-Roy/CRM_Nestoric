import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String?   id;
  final String    userId;
  final String    userName;
  final String    userEmail;
  final DateTime  checkInTime;
  final DateTime? checkOutTime;
  final double?   lat;          // GPS at check-in
  final double?   lng;
  final String    date;         // 'YYYY-MM-DD' — for fast date-scoped queries

  const AttendanceModel({
    this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.checkInTime,
    this.checkOutTime,
    this.lat,
    this.lng,
    required this.date,
  });

  bool get isPresent => true;
  bool get hasCheckedOut => checkOutTime != null;

  /// Total time in office. Returns null while still checked in.
  Duration? get duration => checkOutTime != null
      ? checkOutTime!.difference(checkInTime)
      : null;

  String get durationLabel {
    if (checkOutTime == null) return 'Ongoing';
    final d = checkOutTime!.difference(checkInTime);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  bool get hasLocation => lat != null && lng != null;

  /// ISO date string for today.
  static String todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() => {
    'userId':       userId,
    'userName':     userName,
    'userEmail':    userEmail,
    'checkInTime':  Timestamp.fromDate(checkInTime),
    'checkOutTime': checkOutTime != null ? Timestamp.fromDate(checkOutTime!) : null,
    'lat':          lat,
    'lng':          lng,
    'date':         date,
  };

  factory AttendanceModel.fromMap(Map<String, dynamic> m, String id) =>
      AttendanceModel(
        id:           id,
        userId:       m['userId']     as String? ?? '',
        userName:     m['userName']   as String? ?? '',
        userEmail:    m['userEmail']  as String? ?? '',
        checkInTime:  m['checkInTime']  != null
            ? (m['checkInTime']  as Timestamp).toDate()
            : DateTime.now(),
        checkOutTime: m['checkOutTime'] != null
            ? (m['checkOutTime'] as Timestamp).toDate()
            : null,
        lat:  (m['lat']  as num?)?.toDouble(),
        lng:  (m['lng']  as num?)?.toDouble(),
        date: m['date']  as String? ?? '',
      );

  AttendanceModel copyWith({DateTime? checkOutTime}) => AttendanceModel(
    id:           id,
    userId:       userId,
    userName:     userName,
    userEmail:    userEmail,
    checkInTime:  checkInTime,
    checkOutTime: checkOutTime ?? this.checkOutTime,
    lat:          lat,
    lng:          lng,
    date:         date,
  );
}
