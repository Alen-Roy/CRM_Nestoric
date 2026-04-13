import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/features/client/pages/home_page.dart';
import 'package:flutter/material.dart';

class ActivityContainers extends StatelessWidget {
  const ActivityContainers({super.key, required this.gridItems});
  final List<GridItem> gridItems;

  static const _bgs = [
    AppColors.primaryLight, AppColors.surface,
    AppColors.primaryPale,  AppColors.surface,
  ];
  static const _fgs = [
    AppColors.primary, AppColors.textDark,
    AppColors.primary, AppColors.textDark,
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      primary: false, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gridItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3),
      itemBuilder: (_, i) {
        final item = gridItems[i];
        final bg   = _bgs[i % _bgs.length];
        final fg   = _fgs[i % _fgs.length];
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: item.accent.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(item.icon, size: 20, color: item.accent),
            ),
            const Spacer(),
            Text(item.total, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: fg)),
            const SizedBox(height: 2),
            Text(item.desc, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg.withOpacity(0.6))),
          ]),
        );
      },
    );
  }
}
