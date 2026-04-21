import 'dart:async';
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
    bool clearError = false,
  }) =>
      MeetingSessionState(
        activeSession:
            clearSession ? null : (activeSession ?? this.activeSession),
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

// ── Main provider (salesperson active session) ────────────────────────────────
final meetingSessionProvider =
    NotifierProvider<MeetingSessionNotifier, MeetingSessionState>(
  MeetingSessionNotifier.new,
);

// ── Admin: all currently active sessions ──────────────────────────────────────
final activeSessionsStreamProvider =
    StreamProvider<List<MeetingSessionModel>>((ref) {
  return ref.watch(meetingSessionRepositoryProvider).watchActiveSessions();
});

// ── Admin: live badge per worker ──────────────────────────────────────────────
final workerSessionStreamProvider =
    StreamProvider.family<MeetingSessionModel?, String>((ref, userId) {
  return ref.watch(meetingSessionRepositoryProvider).watchWorkerSession(userId);
});

// ── Admin: full history per worker ────────────────────────────────────────────
final workerMeetingHistoryProvider =
    StreamProvider.family<List<MeetingSessionModel>, String>((ref, userId) {
  return ref.watch(meetingSessionRepositoryProvider).watchWorkerHistory(userId);
});

// ── Lead meeting history ───────────────────────────────────────────────────────
final leadMeetingHistoryProvider =
    StreamProvider.family<List<MeetingSessionModel>, String>((ref, leadId) {
  return ref
      .watch(meetingSessionRepositoryProvider)
      .watchLeadMeetingHistory(leadId);
});

// ── Client meeting history ─────────────────────────────────────────────────────
final clientMeetingHistoryProvider =
    StreamProvider.family<List<MeetingSessionModel>, String>((ref, clientId) {
  return ref
      .watch(meetingSessionRepositoryProvider)
      .watchClientMeetingHistory(clientId);
});

// ── Notifier ──────────────────────────────────────────────────────────────────
class MeetingSessionNotifier extends Notifier<MeetingSessionState> {
  late final MeetingSessionRepository _repo;

  // Timer pushes location update every 30 seconds while meeting is active
  Timer? _locationTimer;
  String? _activeSessionId;

  @override
  MeetingSessionState build() {
    _repo = ref.watch(meetingSessionRepositoryProvider);
    // Cancel timer when provider is disposed
    ref.onDispose(() {
      _locationTimer?.cancel();
    });
    return const MeetingSessionState();
  }

  /// Restore any existing active session (call from initState).
  Future<void> loadActiveSession(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _repo.getActiveSession(userId);
      if (session != null) {
        _activeSessionId = session.id;
        // Restart the location timer if there's already an active session
        _startLocationTimer(session.id!);
      }
      state = MeetingSessionState(activeSession: session);
    } catch (e) {
      state = MeetingSessionState(error: e.toString());
    }
  }

  /// Start meeting: GPS → Firestore write + begin periodic location updates.
  Future<String?> startMeeting({
    required String userId,
    required String workerName,
    required String leadId,
    required String leadName,
    String sourceType = 'lead',
    String? clientId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final position = await _getCurrentPosition();

      final session = MeetingSessionModel(
        userId: userId,
        workerName: workerName,
        sourceType: sourceType,
        leadId: leadId,
        leadName: leadName,
        clientId: clientId,
        status: 'active',
        lat: position.latitude,
        lng: position.longitude,
        startTime: DateTime.now(),
      );

      final newId = await _repo.startSession(session);
      _activeSessionId = newId;

      // Start pushing location every 30 seconds
      _startLocationTimer(newId);

      state = MeetingSessionState(activeSession: session.copyWith(id: newId));
      return null;
    } catch (e) {
      state = MeetingSessionState(error: e.toString());
      return e.toString();
    }
  }

  /// End meeting: stop timer, update Firestore (lat/lng preserved for history).
  Future<String?> endMeeting() async {
    final session = state.activeSession;
    if (session?.id == null) return 'No active session found';

    // Stop location updates immediately
    _locationTimer?.cancel();
    _locationTimer = null;
    _activeSessionId = null;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.endSession(session!.id!);
      state = const MeetingSessionState();
      return null;
    } catch (e) {
      state = MeetingSessionState(error: e.toString());
      return e.toString();
    }
  }

  // ── Periodic location push (every 30 seconds) ──────────────────────────────
  void _startLocationTimer(String sessionId) {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (_activeSessionId == null) return;
      try {
        final pos = await _getBestPosition();
        await _repo.updateLocation(sessionId, pos.latitude, pos.longitude);
      } catch (_) {
        // Silently ignore — location update failures shouldn't crash the meeting
      }
    });
  }

  // ── GPS helpers ────────────────────────────────────────────────────────────
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
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permission permanently denied. Enable it in app settings.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  /// Best-effort position — high accuracy with fallback to last known.
  Future<Position> _getBestPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
      rethrow;
    }
  }
}
