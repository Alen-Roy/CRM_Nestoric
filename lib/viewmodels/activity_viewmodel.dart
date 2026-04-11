import 'package:crm/models/activity_model.dart';
import 'package:crm/repositories/activity_repository.dart';
import 'package:crm/repositories/lead_repository.dart';
import 'package:crm/viewmodels/leads_viewmodel.dart';
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
// Saves the activity AND stamps lastContactedAt on the lead so the
// follow-up reminder resets immediately after any interaction.
class LogActivityNotifier extends Notifier<AsyncValue<void>> {
  late final ActivityRepository _activityRepo;
  late final LeadRepository _leadRepo;

  @override
  AsyncValue<void> build() {
    _activityRepo = ref.watch(activityRepositoryProvider);
    _leadRepo     = ref.watch(leadRepositoryProvider);
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

      // 1. Save the activity
      await _activityRepo.addActivity(ActivityModel(
        leadId: leadId,
        type: type,
        outcome: outcome,
        notes: notes,
        createdAt: DateTime.now(),
        createdBy: user.uid,
      ));

      // 2. Stamp lastContactedAt on the lead so follow-up timer resets.
      //    Non-blocking — errors are swallowed; the activity was already saved.
      try {
        await _leadRepo.stampLastContacted(leadId);
      } catch (_) {}

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteActivity(String activityId) async {
    state = const AsyncValue.loading();
    try {
      await _activityRepo.deleteActivity(activityId);
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
