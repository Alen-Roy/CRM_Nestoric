import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String?   id;
  final String    userId;
  final String    userName;
  final String    userEmail;
  final DateTime  checkInTime;
  final DateTime? checkOutTime;
  final double?   lat;           // GPS at check-in
  final double?   lng;
  final double?   checkOutLat;   // GPS at check-out
  final double?   checkOutLng;
  final String    date;          // 'YYYY-MM-DD' — for fast date-scoped queries
  final bool      failedCheckout; // true when auto-closed after 12 h with no manual checkout

  const AttendanceModel({
    this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.checkInTime,
    this.checkOutTime,
    this.lat,
    this.lng,
    this.checkOutLat,
    this.checkOutLng,
    required this.date,
    this.failedCheckout = false,
  });

  bool get isPresent => true;
  bool get hasCheckedOut => checkOutTime != null;

  /// True when more than 12 hours have elapsed since check-in with no checkout.
  bool get isAutoCheckout =>
      checkOutTime == null &&
      DateTime.now().difference(checkInTime).inHours >= 12;

  /// The synthetic checkout time for auto-checkout records (checkInTime + 12 h).
  DateTime get autoCheckoutTime => checkInTime.add(const Duration(hours: 12));

  /// Total time in office. Returns null while still actively checked in.
  Duration? get duration {
    if (checkOutTime != null) return checkOutTime!.difference(checkInTime);
    if (isAutoCheckout) return const Duration(hours: 12);
    return null;
  }

  String get durationLabel {
    if (checkOutTime == null && isAutoCheckout) return 'Failed to check out';
    if (checkOutTime == null) return 'Ongoing';
    final d = checkOutTime!.difference(checkInTime);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  bool get hasLocation => lat != null && lng != null;
  bool get hasCheckOutLocation => checkOutLat != null && checkOutLng != null;

  /// ISO date string for today.
  static String todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() => {
    'userId':         userId,
    'userName':       userName,
    'userEmail':      userEmail,
    'checkInTime':    Timestamp.fromDate(checkInTime),
    'checkOutTime':   checkOutTime != null ? Timestamp.fromDate(checkOutTime!) : null,
    'lat':            lat,
    'lng':            lng,
    'checkOutLat':    checkOutLat,
    'checkOutLng':    checkOutLng,
    'date':           date,
    'failedCheckout': failedCheckout,
  };

  factory AttendanceModel.fromMap(Map<String, dynamic> m, String id) =>
      AttendanceModel(
        id:             id,
        userId:         m['userId']     as String? ?? '',
        userName:       m['userName']   as String? ?? '',
        userEmail:      m['userEmail']  as String? ?? '',
        checkInTime:  m['checkInTime']  != null
            ? (m['checkInTime']  as Timestamp).toDate()
            : DateTime.now(),
        checkOutTime: m['checkOutTime'] != null
            ? (m['checkOutTime'] as Timestamp).toDate()
            : null,
        lat:            (m['lat']        as num?)?.toDouble(),
        lng:            (m['lng']        as num?)?.toDouble(),
        checkOutLat:    (m['checkOutLat'] as num?)?.toDouble(),
        checkOutLng:    (m['checkOutLng'] as num?)?.toDouble(),
        date:           m['date']  as String? ?? '',
        failedCheckout: m['failedCheckout'] as bool? ?? false,
      );

  AttendanceModel copyWith({
    DateTime? checkOutTime,
    bool? failedCheckout,
    double? checkOutLat,
    double? checkOutLng,
  }) => AttendanceModel(
    id:             id,
    userId:         userId,
    userName:       userName,
    userEmail:      userEmail,
    checkInTime:    checkInTime,
    checkOutTime:   checkOutTime ?? this.checkOutTime,
    lat:            lat,
    lng:            lng,
    checkOutLat:    checkOutLat ?? this.checkOutLat,
    checkOutLng:    checkOutLng ?? this.checkOutLng,
    date:           date,
    failedCheckout: failedCheckout ?? this.failedCheckout,
  );
}
