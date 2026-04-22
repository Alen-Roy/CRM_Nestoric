import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/core/widgets/follow_up_section.dart';
import 'package:crm/features/client/pages/new_lead_page.dart';
import 'package:crm/features/client/pages/task_add_page.dart';
import 'package:crm/models/client_model.dart';
import 'package:crm/models/task_model.dart';
import 'package:crm/viewmodels/auth_viewmodel.dart';
import 'package:crm/viewmodels/client_viewmodel.dart';
import 'package:crm/viewmodels/home_viewmodel.dart';
import 'package:crm/viewmodels/leads_viewmodel.dart';
import 'package:crm/viewmodels/shell_viewmodel.dart';
import 'package:crm/viewmodels/task_viewmodel.dart';
import 'package:crm/models/announcement_model.dart';
import 'package:crm/repositories/announcement_repository.dart';
import 'package:crm/repositories/task_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crm/features/client/components/recent_activities_section.dart'
    show RecentActivity;
import 'package:crm/features/client/pages/attendance_page.dart';
import 'package:crm/features/client/pages/notifications_page.dart';
import 'package:crm/features/client/pages/settings_page.dart';
import 'package:crm/models/attendance_model.dart';
import 'package:crm/viewmodels/attendance_viewmodel.dart';
import 'package:crm/features/client/pages/global_search_page.dart';import 'package:intl/intl.dart';

// ── Data classes ──────────────────────────────────────────────────────────────
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

// ── Recent activities stream ──────────────────────────────────────────────────
// ── Admin-assigned tasks for this worker ─────────────────────────────────────
final adminAssignedTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  return TaskRepository().getAdminAssignedTasks(user.uid);
});

// ── Announcements from manager ────────────────────────────────────────────────
final announcementsStreamProvider = StreamProvider<List<AnnouncementModel>>((ref) {
  return AnnouncementRepository().stream();
});

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
              ? '$label: $outcome'
              : '$label logged';
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

void _showCallClientSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CallClientSheet(ref: ref),
  );
}

// ── HomePage ──────────────────────────────────────────────────────────────────
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(homeStatsProvider);
    final recentAsync = ref.watch(recentActivitiesProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);
    final leadsAsync = ref.watch(leadsProvider);
    final adminTasksAsync = ref.watch(adminAssignedTasksProvider);
    final announcementsAsync = ref.watch(announcementsStreamProvider);
    final user = FirebaseAuth.instance.currentUser;
    final userName =
        user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final firstName = userName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Header ──────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/logo/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi $firstName ',
                        style: const TextStyle(
                          color: AppColors.textMid,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, d MMM').format(DateTime.now()),
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _iconBtn(
                    Icons.search_rounded,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GlobalSearchPage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _NotificationBell(),
                  const SizedBox(width: 8),
                  _iconBtn(
                    Symbols.settings,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Big title ─────────────────────────────────────────────────
              const Text(
                'Your\nDashboard',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),

              // ── Stat pills ────────────────────────────────────────────────
              statsAsync.when(
                data: (s) => _StatPillsRow(
                  tasks: s.tasksToday,
                  newLeads: s.totalLeads,
                  dealsWon: s.dealsWon,
                ),
                loading: () =>
                    const _StatPillsRow(tasks: 0, newLeads: 0, dealsWon: 0),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // ── Attendance card ───────────────────────────────────────────
              _AttendanceCard(onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttendancePage()),
              )),
              const SizedBox(height: 24),

              // ── Revenue card ──────────────────────────────────────────────
              statsAsync.when(
                data: (s) => _RevenueCard(
                  revenue: s.totalRevenue,
                  dealsWon: s.dealsWon,
                  totalLeads: s.totalLeads,
                ),
                loading: () =>
                    const _RevenueCard(revenue: 0, dealsWon: 0, totalLeads: 0),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // ── Pipeline stage strip (NEW) ─────────────────────────────────
              leadsAsync.when(
                data: (leads) => leads.isEmpty
                    ? const SizedBox.shrink()
                    : _PipelineStrip(leads: leads.map((l) => l.stage).toList()),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // ── Manager Notices ───────────────────────────────────────────────
              announcementsAsync.when(
                data: (notices) => notices.isEmpty
                    ? const SizedBox.shrink()
                    : _ManagerNoticesBanner(notices: notices.where((n) => n.isPinned).isNotEmpty
                        ? [notices.firstWhere((n) => n.isPinned, orElse: () => notices.first)]
                        : [notices.first]),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // ── Admin Assigned Tasks ───────────────────────────────────────
              adminTasksAsync.when(
                data: (adminTasks) {
                  final pending = adminTasks.where((t) => !t.isDone).toList();
                  if (pending.isEmpty) return const SizedBox.shrink();
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _AdminTasksSection(tasks: pending),
                    const SizedBox(height: 24),
                  ]);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              // ── Quick actions ─────────────────────────────────────────────
              const _SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 14),
              _QuickActionsGrid(
                actions: [
                  _QAction(
                    icon: Symbols.person_add,
                    label: 'Add Lead',
                    color: AppColors.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NewLeadPage()),
                    ),
                  ),
                  _QAction(
                    icon: Symbols.calendar_month,
                    label: 'Schedule',
                    color: AppColors.primaryGlow,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TaskAddPage(selectedDate: DateTime.now()),
                      ),
                    ),
                  ),
                  _QAction(
                    icon: Symbols.call,
                    label: 'Call Client',
                    color: AppColors.primary,
                    onTap: () => _showCallClientSheet(context, ref),
                  ),
                  _QAction(
                    icon: Symbols.description,
                    label: 'Reports',
                    color: AppColors.primaryMid,
                    onTap: () =>
                        ref.read(currentTabProvider.notifier).state = 4,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Today's Tasks preview (NEW) ───────────────────────────────
              tasksAsync.when(
                data: (tasks) {
                  final today = DateTime.now();
                  final todayTasks =
                      tasks
                          .where(
                            (t) =>
                                t.scheduledAt.year == today.year &&
                                t.scheduledAt.month == today.month &&
                                t.scheduledAt.day == today.day &&
                                !t.isDone,
                          )
                          .toList()
                        ..sort(
                          (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
                        );
                  if (todayTasks.isEmpty) return const SizedBox.shrink();
                  return _TodaysTasksCard(
                    tasks: todayTasks,
                    onSeeAll: () =>
                        ref.read(currentTabProvider.notifier).state = 3,
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // ── Follow-up section ─────────────────────────────────────────
              FollowUpSection(
                onSeeAll: () => ref.read(currentTabProvider.notifier).state = 1,
              ),
              const SizedBox(height: 24),

              // ── Recent activities ─────────────────────────────────────────
              recentAsync.when(
                data: (a) => a.isEmpty
                    ? const SizedBox.shrink()
                    : _RecentActivitiesCard(activities: a),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 110),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textDark, size: 19),
      ),
    );
  }
}

// ── Notification bell with unread dot ────────────────────────────────────────
class _NotificationBell extends ConsumerWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(announcementsStreamProvider);
    final hasUnread = announcementsAsync.maybeWhen(
      data: (list) => list.isNotEmpty,
      orElse: () => false,
    );

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsPage()),
      ),
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Symbols.notifications,
              color: AppColors.textDark, size: 19),
        ),
        if (hasUnread)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ]),
    );
  }
}

// ── Stat pills row ────────────────────────────────────────────────────────────
class _StatPillsRow extends StatelessWidget {
  final int tasks, newLeads, dealsWon;
  const _StatPillsRow({
    required this.tasks,
    required this.newLeads,
    required this.dealsWon,
  });
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _pill(
            '${tasks.toString().padLeft(2, '0')} Tasks',
            AppColors.primary,
            Colors.white,
          ),
          const SizedBox(width: 10),
          _pill(
            '${newLeads.toString().padLeft(2, '0')} Leads',
            AppColors.primaryLight,
            AppColors.primary,
          ),
          const SizedBox(width: 10),
          _pill(
            '${dealsWon.toString().padLeft(2, '0')} Won',
            AppColors.primary,
            Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Revenue card ──────────────────────────────────────────────────────────────
class _RevenueCard extends StatelessWidget {
  final double revenue;
  final int dealsWon, totalLeads;
  const _RevenueCard({
    required this.revenue,
    required this.dealsWon,
    required this.totalLeads,
  });
  @override
  Widget build(BuildContext context) {
    final revenueStr = revenue >= 1000
        ? '₹${(revenue / 1000).toStringAsFixed(1)}k'
        : '₹${revenue.toStringAsFixed(0)}';
    final winRate = totalLeads == 0 ? 0 : (dealsWon / totalLeads * 100).round();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Revenue Summary',
                  style: TextStyle(
                    color: AppColors.textMid,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primaryPale],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primarySoft),
                  ),
                  child: const Text(
                    'This Year',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              revenueStr,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 44,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const Text(
              'Total from won deals',
              style: TextStyle(color: AppColors.textLight, fontSize: 12),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _miniStat('$dealsWon', 'Won', AppColors.primary),
                const SizedBox(width: 10),
                _miniStat('$totalLeads', 'Leads', AppColors.primary),
                const SizedBox(width: 10),
                _miniStat('$winRate%', 'Win Rate', AppColors.primaryMid),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: totalLeads == 0
                    ? 0
                    : (dealsWon / totalLeads).clamp(0.0, 1.0),
                backgroundColor: AppColors.border,
                color: AppColors.primary,
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _dot(AppColors.primary, 'Deals Won'),
                const SizedBox(width: 16),
                _dot(AppColors.border, 'In Pipeline'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.textLight, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c, String label) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(color: AppColors.textLight, fontSize: 11),
      ),
    ],
  );
}

// ── NEW: Pipeline Stage Strip ──────────────────────────────────────────────────
// Shows a horizontal breakdown of how many leads are in each stage
class _PipelineStrip extends StatelessWidget {
  final List<String> leads; // list of stage strings
  const _PipelineStrip({required this.leads});

  static const _stageOrder = ['New', 'Proposal', 'Negotiation', 'Won', 'Lost'];
  static const _stageColors = {
    'New': AppColors.primaryGlow,
    'Proposal': AppColors.primaryMid,
    'Negotiation': AppColors.primary,
    'Won': AppColors.success,
    'Lost': AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final stage in leads) {
      counts[stage] = (counts[stage] ?? 0) + 1;
    }
    final total = leads.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pipeline Overview',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$total total',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Segmented bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: _stageOrder.map((stage) {
                final count = counts[stage] ?? 0;
                final frac = total == 0 ? 0.0 : count / total;
                if (count == 0) return const SizedBox.shrink();
                return Expanded(
                  flex: (frac * 100).round().clamp(1, 100),
                  child: Container(height: 10, color: _stageColors[stage]),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _stageOrder.where((s) => (counts[s] ?? 0) > 0).map((
              stage,
            ) {
              final count = counts[stage] ?? 0;
              final color = _stageColors[stage] ?? AppColors.primaryMid;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$stage ($count)',
                    style: const TextStyle(
                      color: AppColors.textMid,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── NEW: Today's Tasks Preview Card ───────────────────────────────────────────
class _TodaysTasksCard extends StatelessWidget {
  final List<TaskModel> tasks;
  final VoidCallback onSeeAll;
  const _TodaysTasksCard({required this.tasks, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final shown = tasks.take(3).toList();
    final extra = tasks.length - shown.length;
    final fmt = DateFormat('h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _SectionHeader(title: "Today's Tasks"),
            const Spacer(),
            if (tasks.length > 3)
              GestureDetector(
                onTap: onSeeAll,
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ...shown.asMap().entries.map((e) {
                final task = e.value;
                final isLast = e.key == shown.length - 1 && extra == 0;
                final priColor = task.priority == 'High'
                    ? AppColors.danger
                    : task.priority == 'Low'
                    ? AppColors.primary
                    : AppColors.warning;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Priority dot
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: priColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: const TextStyle(
                                    color: AppColors.textDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  fmt.format(task.scheduledAt),
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: priColor.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              task.priority,
                              style: TextStyle(
                                color: priColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                        color: AppColors.divider,
                        height: 1,
                        indent: 38,
                      ),
                  ],
                );
              }),
              // "+ N more" row
              if (extra > 0)
                GestureDetector(
                  onTap: onSeeAll,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.divider)),
                    ),
                    child: Center(
                      child: Text(
                        '+ $extra more task${extra > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────
class _QAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickActionsGrid extends StatelessWidget {
  final List<_QAction> actions;
  const _QuickActionsGrid({required this.actions});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: actions.asMap().entries.map((entry) {
        final i = entry.key;
        final a = entry.value;
        final isLast = i == actions.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 10),
            child: GestureDetector(
              onTap: a.onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: a.color.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            a.color.withOpacity(0.18),
                            a.color.withOpacity(0.06),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(a.icon, color: a.color, size: 22),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      a.label,
                      style: const TextStyle(
                        color: AppColors.textMid,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Recent activities card ────────────────────────────────────────────────────
class _RecentActivitiesCard extends StatelessWidget {
  final List<RecentActivity> activities;
  const _RecentActivitiesCard({required this.activities});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Recent Activities'),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ...activities.asMap().entries.map((e) {
                final a = e.value;
                final isLast = e.key == activities.length - 1;
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 2,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(a.icon, color: AppColors.primary, size: 18),
                      ),
                      title: Text(
                        a.title,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        a.time,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                        color: AppColors.divider,
                        height: 1,
                        indent: 72,
                      ),
                  ],
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Attendance Card ───────────────────────────────────────────────────────────
class _AttendanceCard extends ConsumerWidget {
  final VoidCallback onTap;
  const _AttendanceCard({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(myAttendanceProvider);

    return attendanceAsync.when(
      loading: () => _buildCard(context, status: _AttendanceStatus.loading),
      error: (_, __) => _buildCard(context, status: _AttendanceStatus.unknown),
      data: (records) {
        final todayKey = AttendanceModel.todayKey();
        AttendanceModel? todayRecord;
        try {
          todayRecord = records.firstWhere((r) => r.date == todayKey);
        } catch (_) {
          todayRecord = null;
        }

        if (todayRecord == null) {
          return _buildCard(context, status: _AttendanceStatus.notCheckedIn);
        } else if (todayRecord.hasCheckedOut) {
          return _buildCard(context,
              status: _AttendanceStatus.checkedOut, record: todayRecord);
        } else {
          return _buildCard(context,
              status: _AttendanceStatus.checkedIn, record: todayRecord);
        }
      },
    );
  }

  Widget _buildCard(BuildContext context,
      {required _AttendanceStatus status, AttendanceModel? record}) {
    final fmt = DateFormat('h:mm a');

    final (Color bg, Color accent, IconData icon, String title, String subtitle) =
        switch (status) {
      _AttendanceStatus.notCheckedIn => (
          AppColors.surface,
          AppColors.primary,
          Symbols.how_to_reg,
          'Mark Attendance',
          'You haven\'t checked in today'
        ),
      _AttendanceStatus.checkedIn => (
          AppColors.surface,
          AppColors.success,
          Symbols.login,
          'Checked In',
          'Since ${record != null ? fmt.format(record.checkInTime) : '--'}'
        ),
      _AttendanceStatus.checkedOut => (
          AppColors.surface,
          AppColors.primaryMid,
          Symbols.logout,
          'Attendance Done',
          'Checked out at ${record?.checkOutTime != null ? fmt.format(record!.checkOutTime!) : '--'}'
        ),
      _AttendanceStatus.loading => (
          AppColors.surface,
          AppColors.primaryLight,
          Symbols.how_to_reg,
          'Attendance',
          'Loading…'
        ),
      _AttendanceStatus.unknown => (
          AppColors.surface,
          AppColors.primaryLight,
          Symbols.how_to_reg,
          'Attendance',
          'Tap to view'
        ),
    };

    final bool showChevron = status != _AttendanceStatus.loading;

    return GestureDetector(
      onTap: showChevron ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMid,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Status badge + chevron
            if (status == _AttendanceStatus.checkedIn)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Active',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            if (showChevron)
              Icon(Icons.chevron_right_rounded,
                  color: accent.withOpacity(0.5), size: 22),
          ],
        ),
      ),
    );
  }
}

enum _AttendanceStatus { notCheckedIn, checkedIn, checkedOut, loading, unknown }

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      color: AppColors.textDark,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
  );
}

// ── Call Client Sheet ─────────────────────────────────────────────────────────
class _CallClientSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _CallClientSheet({required this.ref});
  @override
  ConsumerState<_CallClientSheet> createState() => _CallClientSheetState();
}

class _CallClientSheetState extends ConsumerState<_CallClientSheet> {
  String _search = '';
  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(clientsStreamProvider);
    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Symbols.call, color: AppColors.primary, size: 22),
                SizedBox(width: 10),
                Text(
                  'Call a Client',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              style: const TextStyle(color: AppColors.textDark, fontSize: 14),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'Search clients…',
                hintStyle: const TextStyle(color: AppColors.textLight),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textLight,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.border, height: 1),
          Expanded(
            child: clientsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
              error: (_, __) => const Center(
                child: Text(
                  'Failed to load clients.',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ),
              data: (clients) {
                final filtered = _search.isEmpty
                    ? clients
                    : clients
                          .where(
                            (c) =>
                                c.name.toLowerCase().contains(_search) ||
                                c.phone.contains(_search) ||
                                (c.companyName?.toLowerCase().contains(
                                      _search,
                                    ) ??
                                    false),
                          )
                          .toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      clients.isEmpty ? 'No clients yet.' : 'No results found.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(
                    color: AppColors.border,
                    height: 1,
                    indent: 72,
                  ),
                  itemBuilder: (ctx, i) => _ClientCallTile(client: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientCallTile extends StatelessWidget {
  final ClientModel client;
  const _ClientCallTile({required this.client});

  Future<void> _call(BuildContext context) async {
    final raw = client.phone.replaceAll(RegExp(r'[\s\-()]'), '');
    final uri = Uri.parse('tel:$raw');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Clipboard.setData(ClipboardData(text: client.phone));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied: ${client.phone}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppColors.primaryLight,
        child: Text(
          client.name[0].toUpperCase(),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(
        client.name,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        client.phone,
        style: const TextStyle(color: AppColors.textMid, fontSize: 12),
      ),
      trailing: GestureDetector(
        onTap: () => _call(context),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Symbols.call, color: AppColors.primary, size: 18),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Manager Notices Banner (shows on worker home)
// ─────────────────────────────────────────────────────────────────────────────
class _ManagerNoticesBanner extends StatefulWidget {
  final List<AnnouncementModel> notices;
  const _ManagerNoticesBanner({required this.notices});
  @override
  State<_ManagerNoticesBanner> createState() => _ManagerNoticesBannerState();
}

class _ManagerNoticesBannerState extends State<_ManagerNoticesBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed || widget.notices.isEmpty) return const SizedBox.shrink();
    final notice = widget.notices.first;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryGlow],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.30), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.campaign_outlined, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Manager Notice', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 3),
          Text(notice.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(notice.body, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text('— ${notice.adminName}', style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 11)),
        ])),
        GestureDetector(
          onTap: () => setState(() => _dismissed = true),
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.7), size: 16),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Admin Assigned Tasks Section (shows on worker home)
// ─────────────────────────────────────────────────────────────────────────────
class _AdminTasksSection extends ConsumerWidget {
  final List<TaskModel> tasks;
  const _AdminTasksSection({required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shown = tasks.take(3).toList();
    final extra = tasks.length - shown.length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primarySoft),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.assignment_outlined, color: Colors.white, size: 13),
              SizedBox(width: 5),
              Text('Assigned by Manager', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
            child: Text('${tasks.length}', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 16),
        ...shown.map((task) {
          final priColor = task.priority == 'High'
              ? AppColors.danger
              : task.priority == 'Low' ? AppColors.primary : AppColors.warning;
          final isOverdue = task.scheduledAt.isBefore(DateTime.now()) && !task.isDone;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isOverdue ? AppColors.danger.withOpacity(0.3) : AppColors.border),
              ),
              child: Row(children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: priColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(task.title, style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (task.adminNote?.isNotEmpty == true)
                    Text(task.adminNote!, style: const TextStyle(color: AppColors.textMid, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                ])),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                    DateFormat('d MMM').format(task.scheduledAt),
                    style: TextStyle(color: isOverdue ? AppColors.danger : AppColors.textLight, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: priColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(task.priority, style: TextStyle(color: priColor, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ]),
            ),
          );
        }),
        if (extra > 0)
          Center(child: Text('+ $extra more task${extra > 1 ? 's' : ''}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}
