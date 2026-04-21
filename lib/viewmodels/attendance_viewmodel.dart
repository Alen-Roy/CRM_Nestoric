import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/attendance_model.dart';
import 'package:crm/repositories/attendance_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

// ── Employee: personal attendance history ─────────────────────────────────────
final myAttendanceProvider = StreamProvider<List<AttendanceModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  return ref.watch(attendanceRepositoryProvider).watchMyAttendance(user.uid);
});

// ── Admin: today's attendance for all employees ───────────────────────────────
final todayAttendanceProvider = StreamProvider<List<AttendanceModel>>((ref) {
  return ref.watch(attendanceRepositoryProvider).watchTodayAll();
});

// ── Admin: attendance for a chosen date ──────────────────────────────────────
final dateAttendanceProvider =
    StreamProvider.family<List<AttendanceModel>, String>((ref, dateKey) {
  return ref.watch(attendanceRepositoryProvider).watchDateAttendance(dateKey);
});

// ── Admin: all attendance history ─────────────────────────────────────────────
final allAttendanceProvider = StreamProvider<List<AttendanceModel>>((ref) {
  return ref.watch(attendanceRepositoryProvider).watchAllAttendance();
});

// ── Admin: one employee's full history ────────────────────────────────────────
final employeeAttendanceProvider =
    StreamProvider.family<List<AttendanceModel>, String>((ref, userId) {
  return ref.watch(attendanceRepositoryProvider).watchEmployeeHistory(userId);
});

// ── Check-in state for the current employee ───────────────────────────────────
class AttendanceState {
  final AttendanceModel? todayRecord; // null = not checked in yet today
  final bool isLoading;
  final String? error;

  const AttendanceState({
    this.todayRecord,
    this.isLoading = false,
    this.error,
  });

  bool get isCheckedIn  => todayRecord != null;
  bool get hasCheckedOut => todayRecord?.hasCheckedOut == true;

  AttendanceState copyWith({
    AttendanceModel? todayRecord,
    bool clearRecord = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => AttendanceState(
    todayRecord: clearRecord ? null : (todayRecord ?? this.todayRecord),
    isLoading:   isLoading   ?? this.isLoading,
    error:       clearError  ? null : (error ?? this.error),
  );
}

final attendanceProvider =
    NotifierProvider<AttendanceNotifier, AttendanceState>(
        AttendanceNotifier.new);

class AttendanceNotifier extends Notifier<AttendanceState> {
  late final AttendanceRepository _repo;

  @override
  AttendanceState build() {
    _repo = ref.watch(attendanceRepositoryProvider);
    return const AttendanceState();
  }

  /// Load today's record (call once on page open).
  Future<void> loadToday(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final record = await _repo.getTodayRecord(userId);
      state = AttendanceState(todayRecord: record);
    } catch (e) {
      state = AttendanceState(error: e.toString());
    }
  }

  /// Check in: GPS → Firestore.
  Future<String?> checkIn({
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final pos = await _getPosition();
      final now = DateTime.now();
      final record = AttendanceModel(
        userId:      userId,
        userName:    userName,
        userEmail:   userEmail,
        checkInTime: now,
        lat:         pos?.latitude,
        lng:         pos?.longitude,
        date:        AttendanceModel.todayKey(),
      );
      final id = await _repo.checkIn(record);
      // Also update user name in Firestore users collection so it's fresh
      try {
        await FirebaseFirestore.instance
            .collection('users').doc(userId).update({'name': userName});
      } catch (_) {}

      state = AttendanceState(todayRecord:
          AttendanceModel.fromMap(record.toMap()..['checkOutTime'] = null, id));
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return e.toString();
    }
  }

  /// Check out.
  Future<String?> checkOut() async {
    final record = state.todayRecord;
    if (record?.id == null) return 'No active check-in found.';
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.checkOut(record!.id!);
      state = AttendanceState(
        todayRecord: record.copyWith(checkOutTime: DateTime.now()));
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return e.toString();
    }
  }

  // ── GPS ────────────────────────────────────────────────────────────────────
  Future<Position?> _getPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return null;
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } catch (_) {
      return await Geolocator.getLastKnownPosition();
    }
  }
}
