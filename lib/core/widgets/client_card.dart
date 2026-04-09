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

  Color _priorityColor(String p) {
    switch (p) {
      case 'VIP':      return const Color(0xFFFFB86C);
      case 'Active':   return AppColors.success;
      case 'Inactive': return AppColors.textLight;
      default:         return AppColors.secondary;
    }
  }

  Color _priorityBg(String p) {
    switch (p) {
      case 'VIP':      return const Color(0xFFFFB86C).withOpacity(0.12);
      case 'Active':   return AppColors.success.withOpacity(0.10);
      case 'Inactive': return AppColors.border;
      default:         return AppColors.secondary.withOpacity(0.10);
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
                companyName,
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
                      email,
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
                color: _priorityBg(priority),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                priority,
                style: TextStyle(
                  color: _priorityColor(priority),
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
