import 'package:crm/models/meeting_session_model.dart';
import 'package:crm/repositories/meeting_session_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class MeetingSessionState {
  final MeetingSessionModel? activeSession;
  final bool isLoading;
  final String? error;

  const MeetingSessionState({
    this.activeSession,
    this.isLoading = false,
    this.error,
  });

  bool get isInMeeting => activeSession != null;

  MeetingSessionState copyWith({
    MeetingSessionModel? activeSession,
    bool clearSession = false,
    bool? isLoading,
    String? error,
  }) =>
      MeetingSessionState(
        activeSession:
            clearSession ? null : (activeSession ?? this.activeSession),
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}

// ── Provider ──────────────────────────────────────────────────────────────────
final meetingSessionProvider =
    NotifierProvider<MeetingSessionNotifier, MeetingSessionState>(
  MeetingSessionNotifier.new,
);

// ── Admin: stream provider of all active sessions ─────────────────────────────
final activeSessionsStreamProvider =
    StreamProvider<List<MeetingSessionModel>>((ref) {
  return ref
      .watch(meetingSessionRepositoryProvider)
      .watchActiveSessions();
});

// ── Admin: per-worker stream ───────────────────────────────────────────────────
final workerSessionStreamProvider =
    StreamProvider.family<MeetingSessionModel?, String>((ref, userId) {
  return ref
      .watch(meetingSessionRepositoryProvider)
      .watchWorkerSession(userId);
});

// ── Notifier ──────────────────────────────────────────────────────────────────
class MeetingSessionNotifier extends Notifier<MeetingSessionState> {
  late final MeetingSessionRepository _repo;

  @override
  MeetingSessionState build() {
    _repo = ref.watch(meetingSessionRepositoryProvider);
    return const MeetingSessionState();
  }

  /// Call once when the page opens to restore any existing active session.
  Future<void> loadActiveSession(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final session = await _repo.getActiveSession(userId);
      state = MeetingSessionState(activeSession: session);
    } catch (e) {
      state = MeetingSessionState(error: e.toString());
    }
  }

  /// Start meeting: request permission → get GPS → write to Firestore.
  Future<String?> startMeeting({
    required String userId,
    required String workerName,
    required String leadId,
    required String leadName,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      // 1. Location permission
      final position = await _getCurrentPosition();

      // 2. Write session to Firestore
      final session = MeetingSessionModel(
        userId: userId,
        workerName: workerName,
        leadId: leadId,
        leadName: leadName,
        status: 'active',
        lat: position.latitude,
        lng: position.longitude,
        startTime: DateTime.now(),
      );
      final id = await _repo.startSession(session);
      state = MeetingSessionState(
        activeSession: session.copyWith(),
      );
      // Store the returned id in state so we can end the session later.
      state = MeetingSessionState(
        activeSession: MeetingSessionModel(
          id: id,
          userId: session.userId,
          workerName: session.workerName,
          leadId: session.leadId,
          leadName: session.leadName,
          status: 'active',
          lat: session.lat,
          lng: session.lng,
          startTime: session.startTime,
        ),
      );
      return null; // no error
    } catch (e) {
      state = MeetingSessionState(error: e.toString());
      return e.toString();
    }
  }

  /// End meeting: update Firestore, clear state.
  Future<String?> endMeeting() async {
    final session = state.activeSession;
    if (session?.id == null) return 'No active session found';
    state = state.copyWith(isLoading: true);
    try {
      await _repo.endSession(session!.id!);
      state = const MeetingSessionState();
      return null;
    } catch (e) {
      state = MeetingSessionState(error: e.toString());
      return e.toString();
    }
  }

  // ── GPS helper ─────────────────────────────────────────────────────────────
  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
          'Location services are disabled. Please enable GPS and try again.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
            'Location permission denied. Please allow location access.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permission permanently denied. Please enable it in app settings.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }
}
