import 'package:crm/models/lead_model.dart';
import 'package:crm/repositories/client_repository.dart';
import 'package:crm/repositories/lead_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crm/viewmodels/leads_viewmodel.dart';
import 'package:crm/viewmodels/client_viewmodel.dart';

// ── Provider ──────────────────────────────────────────────────────────────────
final leadDetailProvider =
    NotifierProvider<LeadDetailNotifier, AsyncValue<void>>(
      LeadDetailNotifier.new,
    );

// ── Notifier ──────────────────────────────────────────────────────────────────
class LeadDetailNotifier extends Notifier<AsyncValue<void>> {
  late final LeadRepository _repo;
  late final ClientRepository _clientRepo;

  @override
  AsyncValue<void> build() {
    _repo = ref.watch(leadRepositoryProvider);
    _clientRepo = ref.watch(clientRepositoryProvider);
    return const AsyncValue.data(null);
  }

  // ── Move lead to a new stage ──────────────────────────────────────────────
  // When stage is 'Won', also creates a ClientModel in Firestore.
  Future<LeadModel?> updateStage(LeadModel lead, String newStage) async {
    state = const AsyncValue.loading();
    try {
      final now = DateTime.now();
      final updated = lead.copyWith(
        stage: newStage,
        lastContacted: _formatDate(now),
        lastContactedAt: now,
      );
      await _repo.updateLead(updated);

      // Auto-create client when moved to Won
      if (newStage == 'Won') {
        await _clientRepo.createFromLead(updated);
      }

      state = const AsyncValue.data(null);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  // ── Stamp lastContactedAt on a lead after an activity is logged ───────────
  // Called by LogActivityNotifier so the follow-up reminder resets automatically.
  Future<void> stampLastContacted(LeadModel lead) async {
    try {
      final now = DateTime.now();
      await _repo.updateLead(lead.copyWith(
        lastContacted: _formatDate(now),
        lastContactedAt: now,
      ));
    } catch (_) {
      // Non-critical — silently swallow; the activity was already saved.
    }
  }

  // ── Update lead notes ─────────────────────────────────────────────────────
  Future<void> updateNotes(LeadModel lead, String newNotes) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateLead(lead.copyWith(notes: newNotes));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // ── Delete a lead ─────────────────────────────────────────────────────────
  Future<void> deleteLead(String leadId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteLead(leadId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}

// ── Stage order and metadata ──────────────────────────────────────────────────
const List<String> leadStages = [
  'New', 'Proposal', 'Negotiation', 'Won', 'Lost',
];

String? nextStage(String currentStage) {
  const progression = {
    'New': 'Proposal',
    'Proposal': 'Negotiation',
    'Negotiation': 'Won',
  };
  return progression[currentStage];
}

String moveButtonLabel(String currentStage) {
  switch (currentStage) {
    case 'New':         return '→ Move to Proposal';
    case 'Proposal':    return '→ Move to Negotiation';
    case 'Negotiation': return '🏆 Mark as Won!';
    default:            return '';
  }
}
