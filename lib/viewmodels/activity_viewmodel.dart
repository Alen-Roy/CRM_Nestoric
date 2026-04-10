import 'package:crm/models/activity_model.dart';
import 'package:crm/models/lead_model.dart';
import 'package:crm/repositories/activity_repository.dart';
import 'package:crm/repositories/lead_repository.dart';
import 'package:crm/viewmodels/lead_detail_viewmodel.dart';
import 'package:crm/viewmodels/leads_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Repository provider ───────────────────────────────────────────────────────
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository();
});

// ── Activities stream — scoped to a leadId (family provider) ─────────────────
final activitiesProvider =
    StreamProvider.family<List<ActivityModel>, String>((ref, leadId) {
  final repo = ref.watch(activityRepositoryProvider);
  return repo.getActivities(leadId);
});

// ── Log Activity Notifier ─────────────────────────────────────────────────────
class LogActivityNotifier extends Notifier<AsyncValue<void>> {
  late final ActivityRepository _activityRepo;
  late final LeadRepository _leadRepo;

  @override
  AsyncValue<void> build() {
    _activityRepo = ref.watch(activityRepositoryProvider);
    _leadRepo     = ref.watch(leadRepositoryProvider);
    return const AsyncValue.data(null);
  }

  // Saves the activity AND stamps lastContactedAt on the lead so the
  // follow-up reminder resets immediately after any interaction.
  Future<void> logActivity({
    LeadModel? lead,
    String? leadId,
    required ActivityType type,
    String? outcome,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final now = DateTime.now();

      final id = lead?.id ?? leadId;
      if (id == null || id.isEmpty) throw Exception('Lead ID is required');

      // 1. Save the activity
      final activity = ActivityModel(
        leadId: id,
        type: type,
        outcome: outcome,
        notes: notes,
        createdAt: now,
        createdBy: user.uid,
      );
      await _activityRepo.addActivity(activity);

      // 2. Stamp lastContactedAt on the lead (non-blocking — errors swallowed)
      if (lead != null) {
        await ref.read(leadDetailProvider.notifier).stampLastContacted(lead);
      }

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
