import 'package:crm/models/activity_model.dart';
import 'package:crm/repositories/activity_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Repository provider ───────────────────────────────────────────────────────
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository();
});

// ── Activities stream — scoped to a leadId (family provider) ─────────────────
// Usage: ref.watch(activitiesProvider('leadId123'))
final activitiesProvider =
    StreamProvider.family<List<ActivityModel>, String>((ref, leadId) {
  final repo = ref.watch(activityRepositoryProvider);
  return repo.getActivities(leadId);
});

// ── Log Activity Notifier ─────────────────────────────────────────────────────
// Handles the async action of saving a new activity.
class LogActivityNotifier extends Notifier<AsyncValue<void>> {
  late final ActivityRepository _repo;

  @override
  AsyncValue<void> build() {
    _repo = ref.watch(activityRepositoryProvider);
    return const AsyncValue.data(null);
  }

  Future<void> logActivity({
    required String leadId,
    required ActivityType type,
    String? outcome,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final activity = ActivityModel(
        leadId: leadId,
        type: type,
        outcome: outcome,
        notes: notes,
        createdAt: DateTime.now(),
        createdBy: user.uid,
      );

      await _repo.addActivity(activity);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteActivity(String activityId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteActivity(activityId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final logActivityProvider =
    NotifierProvider<LogActivityNotifier, AsyncValue<void>>(
  LogActivityNotifier.new,
);
