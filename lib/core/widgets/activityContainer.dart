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
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final item = gridItems[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF171D29), Color(0xFF0F131C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            border: Border.all(color: item.accent.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: item.accent.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 46,
                width: 46,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: item.accent.withValues(alpha: 0.45),
                  ),
                ),
                child: Icon(item.icon, size: 20, color: item.accent),
              ),
              const SizedBox(height: 8),
              Text(
                item.total,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.desc,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDCE4EE),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.info,
                style: TextStyle(
                  fontSize: 12,
                  color: item.accent.withValues(alpha: 0.88),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
