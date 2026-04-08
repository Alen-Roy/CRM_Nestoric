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
      final updated = lead.copyWith(
        stage: newStage,
        lastContacted: _today(),
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

  String _today() {
    final now = DateTime.now();
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${now.day} ${months[now.month]} ${now.year}';
  }
}

// ── Stage order and metadata ──────────────────────────────────────────────────
const List<String> leadStages = [
  'New',
  'Proposal',
  'Negotiation',
  'Won',
  'Lost',
];

// Returns the next stage after the current one.
// Returns null if already at Won or Lost.
String? nextStage(String currentStage) {
  const progression = {
    'New': 'Proposal',
    'Proposal': 'Negotiation',
    'Negotiation': 'Won',
  };
  return progression[currentStage];
}

// Returns label for the move-forward button.
String moveButtonLabel(String currentStage) {
  switch (currentStage) {
    case 'New':
      return '→ Move to Proposal';
    case 'Proposal':
      return '→ Move to Negotiation';
    case 'Negotiation':
      return '🏆 Mark as Won!';
    default:
      return '';
  }
}
