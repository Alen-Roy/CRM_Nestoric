import 'package:crm/core/widgets/activityContainer.dart';
import 'package:crm/core/widgets/quick_action_containers.dart';
import 'package:crm/features/client/components/recent_activities_section.dart';
import 'package:crm/features/client/pages/new_lead_Page.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class GridItem {
  final IconData icon;
  final Color accent;
  final String total;
  final String desc;
  final String info;
  GridItem({
    required this.icon,
    required this.accent,
    required this.total,
    required this.desc,
    required this.info,
  });
}

class QuickActions {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  QuickActions({required this.icon, required this.label, required this.onTap});
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    void showQuickActionMessage(String label) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('$label tapped'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 900),
        ),
      );
    }

    final List<GridItem> gridItems = [
      GridItem(
        icon: Symbols.leaderboard,
        accent: const Color(0xFF96E1FF),
        total: "1,234",
        desc: "Leads",
        info: "Increased by 10%",
      ),
      GridItem(
        icon: Symbols.thumb_up,
        accent: const Color(0xFFC56BFF),
        total: "567",
        desc: "Deals Won",
        info: "32 closed this week",
      ),
      GridItem(
        icon: Symbols.attach_money,
        accent: const Color(0xFF67D39F),
        total: "\$12,345",
        desc: "Revenue",
        info: "Monthly total",
      ),
      GridItem(
        icon: Symbols.task_alt,
        accent: const Color(0xFFFFC97A),
        total: "89",
        desc: "Tasks Today",
        info: "14 pending",
      ),
    ];
    final List<QuickActions> quickActions = [
      QuickActions(
        icon: Symbols.person_add,
        label: "Add Lead",
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return NewLeadPage();
            },
          ),
        ),
      ),
      QuickActions(
        icon: Symbols.calendar_month,
        label: "Schedule",
        onTap: () => showQuickActionMessage("Schedule"),
      ),
      QuickActions(
        icon: Symbols.call,
        label: "Call Client",
        onTap: () => showQuickActionMessage("Call Client"),
      ),
      QuickActions(
        icon: Symbols.description,
        label: "New Report",
        onTap: () => showQuickActionMessage("New Report"),
      ),
    ];
    final List<RecentActivity> recentActivities = [
      RecentActivity(
        icon: Symbols.call,
        title: "Call with Ravi's Restaurant",
        time: "Today at 3:00 PM",
      ),
      RecentActivity(
        icon: Symbols.mail,
        title: "Proposal sent to Green Foods",
        time: "Today at 1:20 PM",
      ),
      RecentActivity(
        icon: Symbols.event_note,
        title: "Meeting scheduled with Aster Retail",
        time: "Yesterday at 6:15 PM",
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: Image.asset("assets/logo/logo.png").image,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Good Morning,",
                        style: TextStyle(color: Colors.white),
                      ),
                      const Text(
                        "Alen Roy",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Activity Overview",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ActivityContainers(gridItems: gridItems),
              const SizedBox(height: 20),
              Text(
                "Quick Actions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              QuickActionContainers(quickActions: quickActions),
              const SizedBox(height: 20),
              RecentActivitiesSection(
                recentActivities: recentActivities,
                onSeeAllTap: () {},
                onActivityTap: (activity) =>
                    showQuickActionMessage(activity.title),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
