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

  // ── Employee: today's record ──────────────────────────────────────────────
  // Two single-field where clauses — no composite index needed.
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

  // ── Employee: full history — single where, sort in Dart ───────────────────
  Stream<List<AttendanceModel>> watchMyAttendance(String userId) {
    return _col
        .where('userId', isEqualTo: userId)   // single where → no composite index
        .limit(60)
        .snapshots()
        .map((s) {
          final list = s.docs
              .map((d) => AttendanceModel.fromMap(d.data(), d.id))
              .toList();
          list.sort((a, b) => b.checkInTime.compareTo(a.checkInTime)); // newest first
          return list;
        });
  }

  // ── Admin: all records for a date — single where, sort in Dart ───────────
  Stream<List<AttendanceModel>> watchTodayAll() {
    final today = AttendanceModel.todayKey();
    return _watchByDate(today);
  }

  Stream<List<AttendanceModel>> watchDateAttendance(String dateKey) {
    return _watchByDate(dateKey);
  }

  Stream<List<AttendanceModel>> _watchByDate(String dateKey) {
    return _col
        .where('date', isEqualTo: dateKey)    // single where → no composite index
        .snapshots()
        .map((s) {
          final list = s.docs
              .map((d) => AttendanceModel.fromMap(d.data(), d.id))
              .toList();
          list.sort((a, b) => a.checkInTime.compareTo(b.checkInTime)); // earliest first
          return list;
        });
  }

  // ── Admin: all records (no where clause — single-field orderBy is fine) ──
  Stream<List<AttendanceModel>> watchAllAttendance() {
    return _col
        .orderBy('checkInTime', descending: true)
        .limit(200)
        .snapshots()
        .map((s) => s.docs
            .map((d) => AttendanceModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ── Admin: one employee's history — single where, sort in Dart ───────────
  Stream<List<AttendanceModel>> watchEmployeeHistory(String userId) {
    return _col
        .where('userId', isEqualTo: userId)   // single where → no composite index
        .limit(60)
        .snapshots()
        .map((s) {
          final list = s.docs
              .map((d) => AttendanceModel.fromMap(d.data(), d.id))
              .toList();
          list.sort((a, b) => b.checkInTime.compareTo(a.checkInTime)); // newest first
          return list;
        });
  }
}
