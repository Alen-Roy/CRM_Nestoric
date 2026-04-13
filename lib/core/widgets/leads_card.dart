import 'package:crm/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Lead card widget — premium style with left avatar block, info, and stage pill.
class LeadsCard extends StatelessWidget {
  const LeadsCard({
    super.key,
    required this.name,
    this.companyName,
    this.email,
    required this.phone,
    required this.stage,
    required this.lastContacted,
  });

  final String  name;
  final String? companyName;
  final String? email;
  final String  phone;
  final String  stage;
  final String  lastContacted;

  Color _stageColor(String s) {
    switch (s) {
      case 'Won':         return AppColors.primary;
      case 'Proposal':    return AppColors.primarySoft;
      case 'Negotiation': return AppColors.primary;
      case 'New':         return AppColors.primaryGlow;
      default:            return AppColors.textLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _stageColor(stage);
    final initials = name.trim().split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2).join('').toUpperCase();

    return Row(
      children: [
        // Avatar square
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              initials.isEmpty ? '?' : initials,
              style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w700),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(companyName?.isNotEmpty == true ? companyName! : phone,
                  style: const TextStyle(color: AppColors.textMid, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Symbols.call, color: AppColors.textLight, size: 12),
                const SizedBox(width: 4),
                Text(phone, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                if (lastContacted.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  const Icon(Symbols.calendar_today, color: AppColors.textLight, size: 12),
                  const SizedBox(width: 4),
                  Text(lastContacted, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                ],
              ]),
            ],
          ),
        ),

        // Stage badge
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(stage,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }
}
