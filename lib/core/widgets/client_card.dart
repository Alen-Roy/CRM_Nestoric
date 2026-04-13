import 'package:crm/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class clientCard extends StatelessWidget {
  const clientCard({
    super.key,
    required this.name,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.lastContacted,
    required this.priority,
  });

  final String name;
  final String companyName;
  final String email;
  final String phone;
  final String lastContacted;
  final String priority;

  Color _statusColor(String p) {
    switch (p) {
      case 'VIP':      return AppColors.primaryMid;
      case 'Active':   return AppColors.primary;
      case 'Inactive': return AppColors.textLight;
      default:         return AppColors.primaryGlow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color    = _statusColor(priority);
    final initials = name.trim().split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '').take(2).join('').toUpperCase();

    return Row(
      children: [
        // Avatar with status ring
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryLight,
            child: Text(initials.isEmpty ? '?' : initials,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w700),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(companyName, style: const TextStyle(color: AppColors.textMid, fontSize: 12),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Symbols.call, color: AppColors.textLight, size: 12),
                const SizedBox(width: 4),
                Text(phone, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
              ]),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (lastContacted.isNotEmpty)
              Text(lastContacted, style: const TextStyle(color: AppColors.textLight, fontSize: 10)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
              child: Text(priority, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }
}
