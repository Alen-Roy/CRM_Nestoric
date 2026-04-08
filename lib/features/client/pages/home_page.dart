import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/core/widgets/activityContainer.dart';
import 'package:crm/core/widgets/quick_action_containers.dart';
import 'package:crm/features/client/components/recent_activities_section.dart';
import 'package:crm/features/client/pages/new_lead_Page.dart';
import 'package:crm/viewmodels/auth_viewmodel.dart';
import 'package:crm/viewmodels/home_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// ── Recent activities provider ─────────────────────────────────────────────
// Queries activities by createdBy == uid, newest 5.
// Requires Firestore index: createdBy ASC + createdAt DESC (see firestore.indexes.json)
final recentActivitiesProvider = StreamProvider<List<RecentActivity>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('activities')
      .where('createdBy', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .limit(5)
      .snapshots()
      .map(
        (snap) => snap.docs.map((doc) {
          final d = doc.data();
          final type = d['type'] as String? ?? 'note';
          final outcome = d['outcome'] as String?;
          final createdAt = d['createdAt'] != null
              ? (d['createdAt'] as Timestamp).toDate()
              : DateTime.now();
          final label = _typeLabel(type);
          final title = (outcome != null && outcome.isNotEmpty)
              ? '${_typeEmoji(type)} $label: $outcome'
              : '${_typeEmoji(type)} $label logged';
          final diff = DateTime.now().difference(createdAt);
          final time = diff.inMinutes < 60
              ? '${diff.inMinutes}m ago'
              : diff.inHours < 24
              ? '${diff.inHours}h ago'
              : '${diff.inDays}d ago';
          return RecentActivity(
            icon: _typeIcon(type),
            title: title,
            time: time,
          );
        }).toList(),
      );
});

IconData _typeIcon(String t) {
  switch (t) {
    case 'call':
      return Symbols.call;
    case 'meeting':
      return Symbols.handshake;
    case 'email':
      return Symbols.mail;
    case 'proposal':
      return Symbols.description;
    default:
      return Symbols.edit_note;
  }
}

String _typeEmoji(String t) {
  switch (t) {
    case 'call':
      return '📞';
    case 'meeting':
      return '🤝';
    case 'email':
      return '📧';
    case 'proposal':
      return '📄';
    default:
      return '📝';
  }
}

String _typeLabel(String t) {
  switch (t) {
    case 'call':
      return 'Call';
    case 'meeting':
      return 'Meeting';
    case 'email':
      return 'Email';
    case 'proposal':
      return 'Proposal';
    default:
      return 'Note';
  }
}

// ── Page ──────────────────────────────────────────────────────────────────────
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void showMessage(String label) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('$label tapped'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(milliseconds: 900),
          ),
        );
    }

    // Real user name from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    final rawName = user?.displayName?.trim();
    final userName = (rawName != null && rawName.isNotEmpty)
        ? rawName
        : (user?.email?.split('@').first ?? 'User');

    // Live stats
    final statsAsync = ref.watch(homeStatsProvider);
    final List<GridItem> gridItems = statsAsync.maybeWhen(
      data: (s) => [
        GridItem(
          icon: Symbols.leaderboard,
          accent: const Color(0xFF96E1FF),
          total: s.totalLeads.toString(),
          desc: 'Leads',
          info: 'Total in pipeline',
        ),
        GridItem(
          icon: Symbols.thumb_up,
          accent: const Color(0xFFC56BFF),
          total: s.dealsWon.toString(),
          desc: 'Deals Won',
          info: 'Closed deals',
        ),
        GridItem(
          icon: Symbols.attach_money,
          accent: const Color(0xFF67D39F),
          total: s.totalRevenue >= 1000
              ? '₹${(s.totalRevenue / 1000).toStringAsFixed(1)}k'
              : '₹${s.totalRevenue.toStringAsFixed(0)}',
          desc: 'Revenue',
          info: 'From won leads',
        ),
        GridItem(
          icon: Symbols.task_alt,
          accent: const Color(0xFFFFC97A),
          total: s.tasksToday.toString(),
          desc: 'Tasks Today',
          info: 'Pending today',
        ),
      ],
      orElse: () => [
        GridItem(
          icon: Symbols.leaderboard,
          accent: const Color(0xFF96E1FF),
          total: '—',
          desc: 'Leads',
          info: 'Loading...',
        ),
        GridItem(
          icon: Symbols.thumb_up,
          accent: const Color(0xFFC56BFF),
          total: '—',
          desc: 'Deals Won',
          info: 'Loading...',
        ),
        GridItem(
          icon: Symbols.attach_money,
          accent: const Color(0xFF67D39F),
          total: '—',
          desc: 'Revenue',
          info: 'Loading...',
        ),
        GridItem(
          icon: Symbols.task_alt,
          accent: const Color(0xFFFFC97A),
          total: '—',
          desc: 'Tasks Today',
          info: 'Loading...',
        ),
      ],
    );

    final List<QuickActions> quickActions = [
      QuickActions(
        icon: Symbols.person_add,
        label: 'Add Lead',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewLeadPage()),
        ),
      ),
      QuickActions(
        icon: Symbols.calendar_month,
        label: 'Schedule',
        onTap: () => showMessage('Schedule'),
      ),
      QuickActions(
        icon: Symbols.call,
        label: 'Call Client',
        onTap: () => showMessage('Call Client'),
      ),
      QuickActions(
        icon: Symbols.description,
        label: 'New Report',
        onTap: () => showMessage('New Report'),
      ),
    ];

    final recentAsync = ref.watch(recentActivitiesProvider);

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
                    backgroundImage: Image.asset('assets/logo/logo.png').image,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                    icon: const Icon(Symbols.logout, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Activity Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ActivityContainers(gridItems: gridItems),
              const SizedBox(height: 20),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              QuickActionContainers(quickActions: quickActions),
              const SizedBox(height: 20),
              recentAsync.when(
                data: (activities) => activities.isEmpty
                    ? const SizedBox.shrink()
                    : RecentActivitiesSection(
                        recentActivities: activities,
                        onSeeAllTap: () {},
                        onActivityTap: (a) => showMessage(a.title),
                      ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white38,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
