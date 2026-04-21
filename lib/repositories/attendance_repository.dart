import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/attendance_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final attendanceRepositoryProvider =
    Provider<AttendanceRepository>((_) => AttendanceRepository());

class AttendanceRepository {
  final _col = FirebaseFirestore.instance.collection('attendance');

  // ── Employee: check in ────────────────────────────────────────────────────
  Future<String> checkIn(AttendanceModel record) async {
    final ref = await _col.add(record.toMap());
    return ref.id;
  }

  // ── Employee: check out ───────────────────────────────────────────────────
  Future<void> checkOut(String attendanceId) async {
    await _col.doc(attendanceId).update({
      'checkOutTime': FieldValue.serverTimestamp(),
    });
  }

  // ── Employee: today's record (null = not yet checked in) ─────────────────
  Future<AttendanceModel?> getTodayRecord(String userId) async {
    final today = AttendanceModel.todayKey();
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('date',   isEqualTo: today)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return AttendanceModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  // ── Employee: full attendance history (stream) ────────────────────────────
  Stream<List<AttendanceModel>> watchMyAttendance(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('checkInTime', descending: true)
        .limit(60)
        .snapshots()
        .map((s) => s.docs
            .map((d) => AttendanceModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ── Admin: all employees today ────────────────────────────────────────────
  Stream<List<AttendanceModel>> watchTodayAll() {
    final today = AttendanceModel.todayKey();
    return _col
        .where('date', isEqualTo: today)
        .orderBy('checkInTime', descending: false)
        .snapshots()
        .map((s) => s.docs
            .map((d) => AttendanceModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ── Admin: attendance for any date ───────────────────────────────────────
  Stream<List<AttendanceModel>> watchDateAttendance(String dateKey) {
    return _col
        .where('date', isEqualTo: dateKey)
        .orderBy('checkInTime', descending: false)
        .snapshots()
        .map((s) => s.docs
            .map((d) => AttendanceModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ── Admin: all attendance records (last 200, for history view) ───────────
  Stream<List<AttendanceModel>> watchAllAttendance() {
    return _col
        .orderBy('checkInTime', descending: true)
        .limit(200)
        .snapshots()
        .map((s) => s.docs
            .map((d) => AttendanceModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ── Admin: one employee's history ─────────────────────────────────────────
  Stream<List<AttendanceModel>> watchEmployeeHistory(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('checkInTime', descending: true)
        .limit(60)
        .snapshots()
        .map((s) => s.docs
            .map((d) => AttendanceModel.fromMap(d.data(), d.id))
            .toList());
  }
}
