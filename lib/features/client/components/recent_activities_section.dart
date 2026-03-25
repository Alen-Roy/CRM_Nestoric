import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class RecentActivity {
  final IconData icon;
  final String title;
  final String time;

  const RecentActivity({
    required this.icon,
    required this.title,
    required this.time,
  });
}

class RecentActivitiesSection extends StatelessWidget {
  final List<RecentActivity> recentActivities;
  final ValueChanged<RecentActivity>? onActivityTap;
  final VoidCallback? onSeeAllTap;

  const RecentActivitiesSection({
    super.key,
    required this.recentActivities,
    this.onActivityTap,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "Recent Activities",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onSeeAllTap,
              child: Text(
                "See All",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentActivities.isEmpty)
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white30),
            ),
            child: const Center(
              child: Text(
                "No recent activities",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white30),
            ),
            child: Column(
              children: List.generate(recentActivities.length, (index) {
                final activity = recentActivities[index];
                return Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: onActivityTap == null
                          ? null
                          : () => onActivityTap!(activity),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: Icon(
                                activity.icon,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activity.time,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Symbols.chevron_right,
                              color: Colors.white38,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (index != recentActivities.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.white12,
                        indent: 12,
                        endIndent: 12,
                      ),
                  ],
                );
              }),
            ),
          ),
      ],
    );
  }
}
