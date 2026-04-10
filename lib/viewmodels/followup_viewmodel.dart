import 'package:crm/models/lead_model.dart';
import 'package:crm/viewmodels/leads_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Follow-up urgency levels ──────────────────────────────────────────────────
enum FollowUpUrgency { overdue, warning, normal }

class FollowUpLead {
  final LeadModel lead;
  final int daysSinceContact; // days since lastContactedAt (or since createdAt if never contacted)
  final bool neverContacted;  // true if no activity has ever been logged
  final FollowUpUrgency urgency;

  const FollowUpLead({
    required this.lead,
    required this.daysSinceContact,
    required this.neverContacted,
    required this.urgency,
  });
}

// ── Threshold constants ───────────────────────────────────────────────────────
const int _warningDays = 3;   // yellow badge: 3–6 days without contact
const int _overdueDays = 7;   // red badge:    7+ days without contact

// ── Provider ──────────────────────────────────────────────────────────────────
// Derives follow-up leads from the existing leadsProvider stream.
// No extra Firestore queries — pure computation on already-loaded data.
final followUpProvider = Provider<AsyncValue<List<FollowUpLead>>>((ref) {
  final leadsAsync = ref.watch(leadsProvider);

  if (leadsAsync.isLoading) return const AsyncValue.loading();
  if (leadsAsync.hasError) {
    return AsyncValue.error(leadsAsync.error!, leadsAsync.stackTrace!);
  }

  final leads = leadsAsync.value ?? [];
  final now   = DateTime.now();

  final result = <FollowUpLead>[];

  for (final lead in leads) {
    // Skip closed leads — no need to follow up
    if (lead.stage == 'Won' || lead.stage == 'Lost') continue;

    final reference = lead.lastContactedAt ?? lead.createdAt;
    if (reference == null) continue; // no date at all — skip

    final days         = now.difference(reference).inDays;
    final neverContacted = lead.lastContactedAt == null;

    // Only surface leads that have gone quiet for at least _warningDays
    if (days < _warningDays) continue;

    final urgency = days >= _overdueDays
        ? FollowUpUrgency.overdue
        : FollowUpUrgency.warning;

    result.add(FollowUpLead(
      lead: lead,
      daysSinceContact: days,
      neverContacted: neverContacted,
      urgency: urgency,
    ));
  }

  // Sort: most overdue first
  result.sort((a, b) => b.daysSinceContact.compareTo(a.daysSinceContact));

  return AsyncValue.data(result);
});
