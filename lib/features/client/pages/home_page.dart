import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/core/widgets/activityContainer.dart';
import 'package:crm/core/widgets/quick_action_containers.dart';
import 'package:crm/core/widgets/follow_up_section.dart';
import 'package:crm/features/client/components/recent_activities_section.dart';
import 'package:crm/features/client/pages/new_lead_Page.dart';
import 'package:crm/features/client/pages/task_add_page.dart';
import 'package:crm/models/client_model.dart';
import 'package:crm/viewmodels/auth_viewmodel.dart';
import 'package:crm/viewmodels/client_viewmodel.dart';
import 'package:crm/viewmodels/home_viewmodel.dart';
import 'package:crm/viewmodels/shell_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

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

// ── Call Client bottom sheet ──────────────────────────────────────────────────
void _showCallClientSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CallClientSheet(ref: ref),
  );
}

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
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
          // Title
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
          // Search
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
          // Client list
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.person_off,
                          color: AppColors.textLight,
                          size: 42,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          clients.isEmpty
                              ? 'No clients yet.\nWon leads become clients.'
                              : 'No results found.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 13,
                          ),
                        ),
                      ],
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
      // Fallback: copy to clipboard
      await Clipboard.setData(ClipboardData(text: client.phone));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied ${client.phone} to clipboard'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = client.name
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join('')
        .toUpperCase();
    final statusColor = client.status == ClientStatus.vip
        ? AppColors.accent3
        : client.status == ClientStatus.active
        ? AppColors.success
        : AppColors.textLight;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primaryLight,
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      title: Text(
        client.name,
        style: const TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            client.phone,
            style: const TextStyle(color: AppColors.textMid, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              client.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      trailing: GestureDetector(
        onTap: () => _call(context),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Symbols.call, color: AppColors.success, size: 20),
        ),
      ),
      onTap: () => _call(context),
    );
  }
}

// ── HomePage ─────────────────────────────────────────────────────────────────
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  List<GridItem> _loadingGrid() => [
    GridItem(
      icon: Symbols.leaderboard,
      accent: AppColors.secondary,
      total: '—',
      desc: 'Leads',
      info: 'Loading...',
    ),
    GridItem(
      icon: Symbols.thumb_up,
      accent: AppColors.primary,
      total: '—',
      desc: 'Deals Won',
      info: 'Loading...',
    ),
    GridItem(
      icon: Symbols.attach_money,
      accent: AppColors.accent2,
      total: '—',
      desc: 'Revenue',
      info: 'Loading...',
    ),
    GridItem(
      icon: Symbols.task_alt,
      accent: AppColors.accent3,
      total: '—',
      desc: 'Tasks Today',
      info: 'Loading...',
    ),
  ];

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
      // 1 — Add Lead: navigate to NewLeadPage
      QuickActions(
        icon: Symbols.person_add,
        label: 'Add Lead',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewLeadPage()),
        ),
      ),
      // 2 — Schedule: open TaskAddPage with today as default date
      QuickActions(
        icon: Symbols.calendar_month,
        label: 'Schedule',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskAddPage(selectedDate: DateTime.now()),
          ),
        ),
      ),
      // 3 — Call Client: bottom sheet with live clients list
      QuickActions(
        icon: Symbols.call,
        label: 'Call Client',
        onTap: () => _showCallClientSheet(context, ref),
      ),
      // 4 — New Report: switch to the Reports tab (index 4)
      QuickActions(
        icon: Symbols.description,
        label: 'New Report',
        onTap: () => ref.read(currentTabProvider.notifier).state = 4,
      ),
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
                      child: Image.asset(
                        'assets/logo/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: const TextStyle(
                            color: AppColors.textMid,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => ref.read(authProvider.notifier).logout(),
                      icon: const Icon(
                        Symbols.logout,
                        color: AppColors.textMid,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _sectionHeading('Activity Overview'),
              const SizedBox(height: 14),
              ActivityContainers(gridItems: gridItems),
              const SizedBox(height: 24),
              _sectionHeading('Quick Actions'),
              const SizedBox(height: 14),
              QuickActionContainers(quickActions: quickActions),
              const SizedBox(height: 24),
              // ── Follow-up reminders ───────────────────────────────────────
              FollowUpSection(
                onSeeAll: () => ref.read(currentTabProvider.notifier).state = 1,
              ),
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
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
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
    style: const TextStyle(
      color: AppColors.textDark,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
  );
}
