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
        final headerColor = hasOverdue ? AppColors.danger : AppColors.warning;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header ───────────────────────────────────────────
            Row(
              children: [
                const Text('Follow-up Needed',
                    style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: headerColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${items.length}',
                      style: TextStyle(color: headerColor, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
                const Spacer(),
                if (extras > 0)
                  GestureDetector(
                    onTap: onSeeAll,
                    child: const Text('See all',
                        style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Cards ────────────────────────────────────────────────────
            ...shown.asMap().entries.map((e) => _FollowUpCard(item: e.value, index: e.key)),
          ],
        );
      },
    );
  }
}

// ── Individual follow-up card ─────────────────────────────────────────────────
class _FollowUpCard extends StatelessWidget {
  final FollowUpLead item;
  final int index;
  const _FollowUpCard({required this.item, required this.index});

  Color get _urgencyColor => item.urgency == FollowUpUrgency.overdue ? AppColors.danger : AppColors.warning;

  String get _daysLabel {
    if (item.neverContacted) {
      return item.daysSinceContact == 0 ? 'Not contacted yet' : 'Never contacted (${item.daysSinceContact}d)';
    }
    if (item.daysSinceContact == 1) return 'Last contact: yesterday';
    return 'Last contact: ${item.daysSinceContact}d ago';
  }

  // Alternating card backgrounds — dark / light like the screenshot
  Color get _cardBg => index.isEven ? AppColors.cardDark : AppColors.surface;
  Color get _textPrimary => index.isEven ? Colors.white : AppColors.textDark;
  Color get _textSecondary => index.isEven ? Colors.white60 : AppColors.textMid;

  @override
  Widget build(BuildContext context) {
    final lead     = item.lead;
    final initials = lead.name.trim().split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '').take(2).join('').toUpperCase();

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LeadDetailPage(lead: lead))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _cardBg.withValues(alpha: index.isEven ? 0.35 : 0.06),
              blurRadius: 14, offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: _urgencyColor.withValues(alpha: index.isEven ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(initials,
                    style: TextStyle(color: _urgencyColor, fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lead.name,
                      style: TextStyle(color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (lead.companyName != null && lead.companyName!.isNotEmpty)
                    Text(lead.companyName!,
                        style: TextStyle(color: _textSecondary, fontSize: 12),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(children: [
                    Icon(Symbols.schedule, size: 12, color: _urgencyColor),
                    const SizedBox(width: 4),
                    Text(_daysLabel,
                        style: TextStyle(color: _urgencyColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  ]),
                ],
              ),
            ),

            // Right — urgency badge + stage pill
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _urgencyColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.urgency == FollowUpUrgency.overdue ? 'Overdue' : 'Due soon',
                  style: TextStyle(color: _urgencyColor, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 6),
              _StagePill(stage: lead.stage, onDark: index.isEven),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StagePill extends StatelessWidget {
  final String stage;
  final bool onDark;
  const _StagePill({required this.stage, required this.onDark});

  Color _color() {
    switch (stage) {
      case 'New':         return AppColors.secondary;
      case 'Proposal':    return AppColors.warning;
      case 'Negotiation': return AppColors.primaryGlow;
      default:            return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: onDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(stage, style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}
