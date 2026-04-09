import 'package:crm/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

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
  final String name;
  final String? companyName;
  final String? email;
  final String phone;
  final String stage;
  final String lastContacted;

  Color _stageColor(String s) {
    switch (s) {
      case 'Won':       return AppColors.success;
      case 'Proposal':  return AppColors.warning;
      case 'Negotiation': return AppColors.primary;
      case 'New':       return AppColors.secondary;
      default:          return AppColors.textLight;
    }
  }

  Color _stageBg(String s) {
    switch (s) {
      case 'Won':       return AppColors.success.withOpacity(0.1);
      case 'Proposal':  return AppColors.warning.withOpacity(0.1);
      case 'Negotiation': return AppColors.primaryLight;
      case 'New':       return AppColors.secondary.withOpacity(0.1);
      default:          return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                companyName ?? 'No Company',
                style: const TextStyle(color: AppColors.textMid, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Symbols.mail, color: AppColors.textLight, size: 14),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      email ?? 'No Email',
                      style: const TextStyle(color: AppColors.textMid, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Symbols.call, color: AppColors.textLight, size: 14),
                  const SizedBox(width: 5),
                  Text(phone, style: const TextStyle(color: AppColors.textMid, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                const Icon(Symbols.calendar_today, color: AppColors.textLight, size: 12),
                const SizedBox(width: 4),
                Text(lastContacted, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _stageBg(stage),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                stage,
                style: TextStyle(
                  color: _stageColor(stage),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
