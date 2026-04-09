import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/features/client/pages/home_page.dart';
import 'package:flutter/material.dart';

class ActivityContainers extends StatelessWidget {
  const ActivityContainers({super.key, required this.gridItems});

  final List<GridItem> gridItems;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      primary: false,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gridItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final item = gridItems[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: item.accent.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 44,
                width: 44,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: item.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 20, color: item.accent),
              ),
              const SizedBox(height: 10),
              Text(
                item.total,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.desc,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMid,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.info,
                style: TextStyle(
                  fontSize: 11,
                  color: item.accent.withOpacity(0.85),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
