import 'package:crm/features/client/pages/home_page.dart';
import 'package:flutter/material.dart';

class QuickActionContainers extends StatelessWidget {
  const QuickActionContainers({super.key, required this.quickActions});

  final List<QuickActions> quickActions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: quickActions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final action = quickActions[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: action.onTap,
            child: Ink(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white30),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Icon(action.icon, color: Colors.white, size: 26),
                  ),
                  Spacer(),
                  Text(
                    action.label,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
