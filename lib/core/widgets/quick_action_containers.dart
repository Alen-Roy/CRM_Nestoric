import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/features/client/pages/home_page.dart';
import 'package:flutter/material.dart';

/// Premium quick-action row — 4 icon tiles in a single horizontal row.
class QuickActionContainers extends StatelessWidget {
  const QuickActionContainers({super.key, required this.quickActions});
  final List<QuickActions> quickActions;

  // Distinct accent per slot
  static const _accents = [AppColors.primary, AppColors.primaryGlow, AppColors.primary, AppColors.primaryMid];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(quickActions.length, (i) {
        final action = quickActions[i];
        final color  = _accents[i % _accents.length];
        return GestureDetector(
          onTap: action.onTap,
          child: Column(
            children: [
              Container(
                width: 62, height: 62,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.18), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Icon(action.icon, color: color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: const TextStyle(color: AppColors.textMid, fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}
