import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/features/client/pages/lead_detail_page.dart';
import 'package:crm/viewmodels/followup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class FollowUpSection extends ConsumerWidget {
  final VoidCallback onSeeAll;
  const FollowUpSection({super.key, required this.onSeeAll});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followUpAsync = ref.watch(followUpProvider);
    return followUpAsync.when(
      loading: () => const SizedBox.shrink(),
      error:   (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final shown      = items.take(4).toList();
        final extras     = items.length - shown.length;
        final hasOverdue = items.any((i) => i.urgency == FollowUpUrgency.overdue);
        final headerColor = hasOverdue ? AppColors.danger : AppColors.primaryGlow;

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Follow-up Needed',
                style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: headerColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text('${items.length}', style: TextStyle(color: headerColor, fontSize: 11, fontWeight: FontWeight.w800)),
            ),
            const Spacer(),
            if (extras > 0)
              GestureDetector(onTap: onSeeAll,
                child: const Text('See all', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 14),
          ...shown.asMap().entries.map((e) => _FollowUpCard(item: e.value, index: e.key)),
        ]);
      },
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  final FollowUpLead item;
  final int index;
  const _FollowUpCard({required this.item, required this.index});

  Color get _urgencyColor => item.urgency == FollowUpUrgency.overdue ? AppColors.danger : AppColors.primaryGlow;
  String get _daysLabel {
    if (item.neverContacted) return item.daysSinceContact == 0 ? 'Not contacted yet' : 'Never contacted (${item.daysSinceContact}d)';
    if (item.daysSinceContact == 1) return 'Last contact: yesterday';
    return 'Last contact: ${item.daysSinceContact}d ago';
  }
  // All light — alternate between white and primaryPale
  Color get _cardBg => index.isEven ? AppColors.surface : AppColors.primaryPale;

  @override
  Widget build(BuildContext context) {
    final lead     = item.lead;
    final initials = lead.name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join('').toUpperCase();

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LeadDetailPage(lead: lead))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: _urgencyColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Text(initials, style: TextStyle(color: _urgencyColor, fontWeight: FontWeight.w800, fontSize: 15))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lead.name, style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
            if (lead.companyName?.isNotEmpty == true)
              Text(lead.companyName!, style: const TextStyle(color: AppColors.textMid, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Row(children: [
              Icon(Symbols.schedule, size: 12, color: _urgencyColor),
              const SizedBox(width: 4),
              Text(_daysLabel, style: TextStyle(color: _urgencyColor, fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _urgencyColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(item.urgency == FollowUpUrgency.overdue ? 'Overdue' : 'Due soon',
                  style: TextStyle(color: _urgencyColor, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 6),
            _StagePill(stage: lead.stage),
          ]),
        ]),
      ),
    );
  }
}

class _StagePill extends StatelessWidget {
  final String stage;
  const _StagePill({required this.stage});
  Color _color() {
    switch (stage) {
      case 'New':         return AppColors.primaryMid;
      case 'Proposal':    return AppColors.primaryGlow;
      case 'Negotiation': return AppColors.primary;
      default:            return AppColors.textLight;
    }
  }
  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(stage, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
