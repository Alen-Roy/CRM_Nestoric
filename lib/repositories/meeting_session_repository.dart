import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/models/meeting_session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final meetingSessionRepositoryProvider =
    Provider<MeetingSessionRepository>((_) => MeetingSessionRepository());

class MeetingSessionRepository {
  final _col =
      FirebaseFirestore.instance.collection('meeting_sessions');

  // ── Salesperson: start a new meeting session ──────────────────────────────
  Future<String> startSession(MeetingSessionModel session) async {
    final ref = await _col.add(session.toMap());
    return ref.id;
  }

  // ── Salesperson: end a session (clears lat/lng, sets endTime) ────────────
  Future<void> endSession(String sessionId) async {
    await _col.doc(sessionId).update({
      'status': 'ended',
      'lat': null,
      'lng': null,
      'endTime': FieldValue.serverTimestamp(),
    });
  }

  // ── Salesperson: check if they already have an active session ────────────
  Future<MeetingSessionModel?> getActiveSession(String userId) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return MeetingSessionModel.fromMap(doc.data(), doc.id);
  }

  // ── Admin: real-time stream of ALL active sessions ────────────────────────
  Stream<List<MeetingSessionModel>> watchActiveSessions() {
    return _col
        .where('status', isEqualTo: 'active')
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MeetingSessionModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ── Admin: active session for a specific worker ───────────────────────────
  Stream<MeetingSessionModel?> watchWorkerSession(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return MeetingSessionModel.fromMap(doc.data(), doc.id);
    });
  }
}
