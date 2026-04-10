import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/features/client/pages/lead_detail_page.dart';
import 'package:crm/viewmodels/followup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class FollowUpSection extends ConsumerWidget {
  /// Called when the user taps "See all" — typically switches to Leads tab.
  final VoidCallback onSeeAll;

  const FollowUpSection({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followUpAsync = ref.watch(followUpProvider);

    return followUpAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        // Show at most 4 on the home screen
        final shown  = items.take(4).toList();
        final extras = items.length - shown.length;

        // Header badge colour: red if any overdue, amber if just warnings
        final hasOverdue = items.any((i) => i.urgency == FollowUpUrgency.overdue);
        final headerColor = hasOverdue ? AppColors.danger : AppColors.warning;
        final headerBg    = hasOverdue
            ? AppColors.danger.withOpacity(0.10)
            : AppColors.warning.withOpacity(0.10);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header ────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: headerBg, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Symbols.notifications_active, color: headerColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Follow-up Needed',
                        style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${items.length} lead${items.length == 1 ? '' : 's'} waiting',
                        style: TextStyle(color: headerColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (extras > 0)
                  GestureDetector(
                    onTap: onSeeAll,
                    child: Text(
                      '+$extras more',
                      style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Cards ─────────────────────────────────────────────────────
            ...shown.map((item) => _FollowUpCard(item: item)),
          ],
        );
      },
    );
  }
}

// ── Individual follow-up card ─────────────────────────────────────────────────
class _FollowUpCard extends StatelessWidget {
  final FollowUpLead item;
  const _FollowUpCard({required this.item});

  Color get _urgencyColor => item.urgency == FollowUpUrgency.overdue
      ? AppColors.danger
      : AppColors.warning;

  Color get _urgencyBg => item.urgency == FollowUpUrgency.overdue
      ? AppColors.danger.withOpacity(0.08)
      : AppColors.warning.withOpacity(0.08);

  String get _daysLabel {
    if (item.neverContacted) {
      return item.daysSinceContact == 0
          ? 'Added today — not yet contacted'
          : 'Not contacted yet (${item.daysSinceContact}d old)';
    }
    if (item.daysSinceContact == 1) return 'Last contact: yesterday';
    return 'Last contact: ${item.daysSinceContact} days ago';
  }

  String get _urgencyBadge => item.urgency == FollowUpUrgency.overdue
      ? '🔴 Overdue'
      : '🟡 Due soon';

  @override
  Widget build(BuildContext context) {
    final lead     = item.lead;
    final initials = lead.name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join('').toUpperCase();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LeadDetailPage(lead: lead)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _urgencyColor.withOpacity(0.25), width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: _urgencyBg,
              child: Text(initials, style: TextStyle(color: _urgencyColor, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lead.name, style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (lead.companyName != null && lead.companyName!.isNotEmpty)
                    Text(lead.companyName!, style: const TextStyle(color: AppColors.textMid, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Symbols.schedule, size: 12, color: _urgencyColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(_daysLabel, style: TextStyle(color: _urgencyColor, fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right side — stage + badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_urgencyBadge, style: TextStyle(color: _urgencyColor, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                _StagePill(stage: lead.stage),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StagePill extends StatelessWidget {
  final String stage;
  const _StagePill({required this.stage});

  Color _color() {
    switch (stage) {
      case 'New':         return AppColors.secondary;
      case 'Proposal':    return AppColors.warning;
      case 'Negotiation': return AppColors.primary;
      default:            return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(stage, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
