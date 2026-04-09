import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/core/constants/app_colors.dart';
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
  GridItem({required this.icon, required this.accent, required this.total, required this.desc, required this.info});
}

class QuickActions {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  QuickActions({required this.icon, required this.label, required this.onTap});
}

final recentActivitiesProvider = StreamProvider<List<RecentActivity>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('activities')
      .where('createdBy', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .limit(5)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
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
            return RecentActivity(icon: _typeIcon(type), title: title, time: time);
          }).toList());
});

IconData _typeIcon(String t) {
  switch (t) {
    case 'call':     return Symbols.call;
    case 'meeting':  return Symbols.handshake;
    case 'email':    return Symbols.mail;
    case 'proposal': return Symbols.description;
    default:         return Symbols.edit_note;
  }
}

String _typeEmoji(String t) {
  switch (t) {
    case 'call':     return '📞';
    case 'meeting':  return '🤝';
    case 'email':    return '📧';
    case 'proposal': return '📄';
    default:         return '📝';
  }
}

String _typeLabel(String t) {
  switch (t) {
    case 'call':     return 'Call';
    case 'meeting':  return 'Meeting';
    case 'email':    return 'Email';
    case 'proposal': return 'Proposal';
    default:         return 'Note';
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  List<GridItem> _loadingGrid() => [
    GridItem(icon: Symbols.leaderboard, accent: AppColors.secondary, total: '—', desc: 'Leads', info: 'Loading...'),
    GridItem(icon: Symbols.thumb_up, accent: AppColors.primary, total: '—', desc: 'Deals Won', info: 'Loading...'),
    GridItem(icon: Symbols.attach_money, accent: AppColors.accent2, total: '—', desc: 'Revenue', info: 'Loading...'),
    GridItem(icon: Symbols.task_alt, accent: AppColors.accent3, total: '—', desc: 'Tasks Today', info: 'Loading...'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void showMessage(String label) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('$label tapped'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 900),
        ));
    }

    final user = FirebaseAuth.instance.currentUser;
    final rawName = user?.displayName?.trim();
    final userName = (rawName != null && rawName.isNotEmpty)
        ? rawName
        : (user?.email?.split('@').first ?? 'User');

    final statsAsync = ref.watch(homeStatsProvider);

    final List<GridItem> gridItems = statsAsync.when(
      loading: () => _loadingGrid(),
      error: (_, __) => _loadingGrid(),
      data: (s) => [
        GridItem(
          icon: Symbols.leaderboard,
          accent: AppColors.secondary,
          total: s.totalLeads.toString(),
          desc: 'Leads',
          info: 'Total in pipeline',
        ),
        GridItem(
          icon: Symbols.thumb_up,
          accent: AppColors.primary,
          total: s.dealsWon.toString(),
          desc: 'Deals Won',
          info: 'Closed deals',
        ),
        GridItem(
          icon: Symbols.attach_money,
          accent: AppColors.accent2,
          total: s.totalRevenue >= 1000
              ? '₹${(s.totalRevenue / 1000).toStringAsFixed(1)}k'
              : '₹${s.totalRevenue.toStringAsFixed(0)}',
          desc: 'Revenue',
          info: 'From won leads',
        ),
        GridItem(
          icon: Symbols.task_alt,
          accent: AppColors.accent3,
          total: s.tasksToday.toString(),
          desc: 'Tasks Today',
          info: 'Pending today',
        ),
      ],
    );

    final List<QuickActions> quickActions = [
      QuickActions(icon: Symbols.person_add, label: 'Add Lead', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewLeadPage()))),
      QuickActions(icon: Symbols.calendar_month, label: 'Schedule', onTap: () => showMessage('Schedule')),
      QuickActions(icon: Symbols.call, label: 'Call Client', onTap: () => showMessage('Call Client')),
      QuickActions(icon: Symbols.description, label: 'New Report', onTap: () => showMessage('New Report')),
    ];

    final recentAsync = ref.watch(recentActivitiesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // ── Header ────────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset('assets/logo/logo.png', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting(), style: const TextStyle(color: AppColors.textMid, fontSize: 13)),
                        Text(userName, style: const TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => ref.read(authProvider.notifier).logout(),
                      icon: const Icon(Symbols.logout, color: AppColors.textMid, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // ── Section heading ───────────────────────────────────────────
              _sectionHeading('Activity Overview'),
              const SizedBox(height: 14),
              ActivityContainers(gridItems: gridItems),
              const SizedBox(height: 24),
              _sectionHeading('Quick Actions'),
              const SizedBox(height: 14),
              QuickActionContainers(quickActions: quickActions),
              const SizedBox(height: 24),
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
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeading(String title) => Text(
    title,
    style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700),
  );
}
