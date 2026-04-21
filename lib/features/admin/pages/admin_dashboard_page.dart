import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/models/attendance_model.dart';
import 'package:crm/viewmodels/attendance_viewmodel.dart';
import 'package:crm/viewmodels/meeting_session_viewmodel.dart';
import 'package:crm/features/admin/pages/meeting_history_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crm/features/admin/pages/worker_report_page.dart';
import 'package:crm/features/admin/viewmodels/admin_viewmodel.dart';
import 'package:crm/features/auth/pages/login_page.dart';
import 'package:crm/models/activity_model.dart';
import 'package:crm/models/announcement_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:crm/models/client_model.dart';
import 'package:crm/models/lead_model.dart';
import 'package:crm/models/user_models.dart';
import 'package:crm/viewmodels/auth_viewmodel.dart';
import 'package:crm/viewmodels/user_role_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Admin Dashboard Page  (6 tabs)
// ─────────────────────────────────────────────────────────────────────────────
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  // 0=Overview 1=Leads 2=Workers 3=Clients 4=Users 5=Notices

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 7, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  void _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email?.split('@').first ?? 'Admin';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _AdminHeader(name: name, onLogout: _logout),
          _AdminTabBar(controller: _tabs),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _OverviewTab(),
                _AllLeadsTab(),
                _WorkersTab(),
                _AllClientsTab(),
                _UsersTab(),
                _AnnouncementsTab(),
                _AttendanceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _AdminHeader extends StatelessWidget {
  final String name;
  final VoidCallback onLogout;
  const _AdminHeader({required this.name, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Symbols.shield_person, color: Colors.white, size: 14),
                        SizedBox(width: 5),
                        Text('Manager', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onLogout,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Symbols.logout, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Welcome, $name',
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Text(DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom 5-tab Tab Bar  (scrollable)
// ─────────────────────────────────────────────────────────────────────────────
class _AdminTabBar extends StatelessWidget {
  final TabController controller;
  const _AdminTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final labels = ['Overview', 'Leads', 'Workers', 'Clients', 'Users', 'Notices', 'Attendance'];
    final icons  = [Symbols.dashboard, Symbols.leaderboard, Symbols.groups, Symbols.business, Symbols.manage_accounts, Symbols.campaign, Symbols.how_to_reg];

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (_, i) {
          final selected = controller.index == i;
          return GestureDetector(
            onTap: () => controller.animateTo(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                boxShadow: selected
                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icons[i], color: selected ? Colors.white : AppColors.textMid, size: 16),
                  const SizedBox(width: 6),
                  Text(labels[i],
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textMid,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────
Widget _loadingCard() => Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
    );

Widget _errorCard(String msg) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(16)),
      child: Text(msg, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
    );

Widget _emptyCard(String msg) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(child: Text(msg, style: const TextStyle(color: AppColors.textLight, fontSize: 14))),
    );

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w800));
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — Overview
// ─────────────────────────────────────────────────────────────────────────────
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync   = ref.watch(adminStatsProvider);
    final leadsAsync   = ref.watch(adminAllLeadsProvider);
    final leaderAsync  = ref.watch(adminLeaderboardProvider);
    final feedAsync    = ref.watch(adminActivityFeedProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        // ── KPI Grid ─────────────────────────────────────────────────────
        statsAsync.when(
          loading: _loadingCard,
          error:   (e, _) => _errorCard('$e'),
          data:    (s) => _KpiGrid(stats: s),
        ),
        const SizedBox(height: 24),

        // ── Pipeline bar ─────────────────────────────────────────────────
        leadsAsync.when(
          loading: _loadingCard,
          error:   (e, _) => _errorCard('$e'),
          data: (leads) => leads.isEmpty ? const SizedBox.shrink() : _PipelineCard(leads: leads),
        ),
        const SizedBox(height: 24),

        // ── Leaderboard ───────────────────────────────────────────────────
        const _SectionLabel('🏆  Leaderboard'),
        const SizedBox(height: 12),
        leaderAsync.when(
          loading: _loadingCard,
          error:   (e, _) => _errorCard('$e'),
          data: (entries) => entries.isEmpty
              ? _emptyCard('No leads yet')
              : _LeaderboardCard(entries: entries),
        ),
        const SizedBox(height: 24),

        // ── Live Activity Feed ─────────────────────────────────────────────
        const _SectionLabel('📡  Live Activity'),
        const SizedBox(height: 12),
        feedAsync.when(
          loading: _loadingCard,
          error:   (e, _) => _errorCard('$e'),
          data: (feed) => feed.isEmpty
              ? _emptyCard('No activities yet')
              : _ActivityFeedCard(feed: feed),
        ),
      ],
    );
  }
}

// ── KPI Grid ──────────────────────────────────────────────────────────────────
class _KpiGrid extends StatelessWidget {
  final AdminStats stats;
  const _KpiGrid({required this.stats});

  String _fmt(double v) => v >= 1000 ? '₹${(v / 1000).toStringAsFixed(1)}k' : '₹${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiData(icon: Symbols.currency_rupee, label: 'Total Revenue',   value: _fmt(stats.totalRevenue), color: AppColors.primary),
      _KpiData(icon: Symbols.person_add,     label: 'Total Leads',     value: '${stats.totalLeads}',    color: AppColors.primaryGlow),
      _KpiData(icon: Symbols.business,       label: 'Clients',         value: '${stats.totalClients}',  color: AppColors.primaryMid),
      _KpiData(icon: Symbols.trending_up,    label: 'Win Rate',        value: '${stats.winRate.toStringAsFixed(0)}%', color: AppColors.success),
      _KpiData(icon: Symbols.emoji_events,   label: 'Won Deals',       value: '${stats.dealsWon}',      color: AppColors.warning),
      _KpiData(icon: Symbols.group,          label: 'Team Size',       value: '${stats.totalUsers}',    color: AppColors.primaryGlow),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: 0.95, crossAxisSpacing: 12, mainAxisSpacing: 12,
      ),
      itemCount: cards.length,
      itemBuilder: (_, i) => _KpiCard(data: cards[i]),
    );
  }
}

class _KpiData {
  final IconData icon; final String label, value; final Color color;
  const _KpiData({required this.icon, required this.label, required this.value, required this.color});
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border),
      boxShadow: [BoxShadow(color: data.color.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: data.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(data.icon, color: data.color, size: 18),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.value, style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w800)),
            Text(data.label, style: const TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    ),
  );
}

// ── Pipeline Card ─────────────────────────────────────────────────────────────
class _PipelineCard extends StatelessWidget {
  final List<LeadModel> leads;
  const _PipelineCard({required this.leads});

  static const _stages = ['New', 'Proposal', 'Negotiation', 'Won', 'Lost'];
  static const _colors = {
    'New': AppColors.primaryGlow, 'Proposal': AppColors.primaryMid, 'Negotiation': AppColors.primary,
    'Won': AppColors.success, 'Lost': AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final l in leads) { counts[l.stage] = (counts[l.stage] ?? 0) + 1; }
    final total = leads.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pipeline — All Teams', style: TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w700)),
              _pill('$total total'),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: _stages.map((s) {
                final c = counts[s] ?? 0;
                if (c == 0) return const SizedBox.shrink();
                return Expanded(
                  flex: (c / total * 100).round().clamp(1, 100),
                  child: Container(height: 12, color: _colors[s] ?? AppColors.primaryMid),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12, runSpacing: 8,
            children: _stages.where((s) => (counts[s] ?? 0) > 0).map((s) {
              final color = _colors[s] ?? AppColors.primaryMid;
              return Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 5),
                Text('$s (${counts[s]})', style: const TextStyle(color: AppColors.textMid, fontSize: 11, fontWeight: FontWeight.w500)),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _pill(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
    child: Text(t, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
  );
}

// ── Leaderboard Card ──────────────────────────────────────────────────────────
class _LeaderboardCard extends StatelessWidget {
  final List<LeaderEntry> entries;
  const _LeaderboardCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    final shown  = entries.take(8).toList();
    final medals = ['🥇', '🥈', '🥉'];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: shown.asMap().entries.map((e) {
          final idx   = e.key;
          final entry = e.value;
          final isLast = idx == shown.length - 1;
          final medal  = idx < 3 ? medals[idx] : '${idx + 1}';
          final revStr = entry.revenue >= 1000
              ? '₹${(entry.revenue / 1000).toStringAsFixed(1)}k'
              : '₹${entry.revenue.toStringAsFixed(0)}';
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(children: [
                SizedBox(width: 28, child: Text(medal, style: const TextStyle(fontSize: 18))),
                const SizedBox(width: 10),
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(
                    (entry.name.isNotEmpty ? entry.name[0] : '?').toUpperCase(),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16),
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.name, style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('${entry.wonCount} won / ${entry.totalLeads} leads',
                          style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                    ],
                  ),
                ),
                Text(revStr, style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w800)),
              ]),
            ),
            if (!isLast) const Divider(color: AppColors.border, height: 1),
          ]);
        }).toList(),
      ),
    );
  }
}

// ── Activity Feed Card ────────────────────────────────────────────────────────
class _ActivityFeedCard extends ConsumerWidget {
  final List<ActivityFeedEntry> feed;
  const _ActivityFeedCard({required this.feed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: feed.asMap().entries.map((e) {
          final idx   = e.key;
          final entry = e.value;
          final isLast = idx == feed.length - 1;
          final color  = _typeColor(entry.activity.type);
          final diff   = DateTime.now().difference(entry.activity.createdAt);
          final time   = diff.inDays > 0 ? '${diff.inDays}d ago' : diff.inHours > 0 ? '${diff.inHours}h ago' : '${diff.inMinutes}m ago';

          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(entry.activity.type.icon, color: color, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                        children: [
                          TextSpan(text: entry.workerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                          TextSpan(text: ' logged a ${entry.activity.type.label.toLowerCase()}'),
                        ],
                      )),
                      Text('on ${entry.leadName}', style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                    ],
                  ),
                ),
                Text(time, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
              ]),
            ),
            if (!isLast) const Divider(color: AppColors.border, height: 1, indent: 16, endIndent: 16),
          ]);
        }).toList(),
      ),
    );
  }

  Color _typeColor(ActivityType t) {
    switch (t) {
      case ActivityType.call:     return AppColors.success;
      case ActivityType.meeting:  return AppColors.primary;
      case ActivityType.email:    return AppColors.primaryMid;
      case ActivityType.proposal: return AppColors.warning;
      case ActivityType.note:     return AppColors.primaryGlow;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — All Leads
// ─────────────────────────────────────────────────────────────────────────────
class _AllLeadsTab extends ConsumerStatefulWidget {
  const _AllLeadsTab();
  @override
  ConsumerState<_AllLeadsTab> createState() => _AllLeadsTabState();
}

class _AllLeadsTabState extends ConsumerState<_AllLeadsTab> {
  String _stageFilter = 'All';

  static const _stageFilters = ['All', 'New', 'Proposal', 'Negotiation', 'Won', 'Lost'];
  static const _stageColors  = {
    'New': AppColors.primaryGlow, 'Proposal': AppColors.primaryMid, 'Negotiation': AppColors.primary,
    'Won': AppColors.success, 'Lost': AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(adminAllLeadsProvider);

    return leadsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
      error:   (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
      data: (leads) {
        final filtered = _stageFilter == 'All'
            ? leads : leads.where((l) => l.stage == _stageFilter).toList();
        return Column(children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _stageFilters.map((s) {
                  final sel   = s == _stageFilter;
                  final color = _stageColors[s] ?? AppColors.primary;
                  return GestureDetector(
                    onTap: () => setState(() => _stageFilter = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel ? color : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? color : AppColors.border),
                      ),
                      child: Text(s, style: TextStyle(color: sel ? Colors.white : AppColors.textMid, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              Text('${filtered.length} leads', style: const TextStyle(color: AppColors.textMid, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No leads in this stage', style: TextStyle(color: AppColors.textLight)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _LeadListTile(lead: filtered[i]),
                  ),
          ),
        ]);
      },
    );
  }
}

class _LeadListTile extends StatelessWidget {
  final LeadModel lead;
  const _LeadListTile({required this.lead});

  static const _stageColors = {
    'New': AppColors.primaryGlow, 'Proposal': AppColors.primaryMid, 'Negotiation': AppColors.primary,
    'Won': AppColors.success, 'Lost': AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final stageColor = _stageColors[lead.stage] ?? AppColors.primaryMid;
    final amountStr  = lead.amount != null && lead.amount!.isNotEmpty ? '₹${lead.amount}' : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: stageColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(
            lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
            style: TextStyle(color: stageColor, fontSize: 17, fontWeight: FontWeight.w800),
          )),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lead.name, style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(lead.companyName ?? lead.phone, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
              if (lead.assignTo?.isNotEmpty == true)
                Text('Assigned to ${lead.assignTo}', style: const TextStyle(color: AppColors.textMid, fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(amountStr, style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: stageColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(lead.stage, style: TextStyle(color: stageColor, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 — Workers
// ─────────────────────────────────────────────────────────────────────────────
class _WorkersTab extends ConsumerWidget {
  const _WorkersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(adminWorkerSummariesProvider);

    return summariesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
      error:   (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
      data: (summaries) {
        if (summaries.isEmpty) {
          return Center(child: _emptyCard('No workers yet'));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: summaries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _WorkerCard(
            summary: summaries[i],
            rank: i + 1,
          ),
        );
      },
    );
  }
}

class _WorkerCard extends ConsumerWidget {
  final WorkerSummary summary;
  final int rank;
  const _WorkerCard({required this.summary, required this.rank});

  String _fmt(double v) => v >= 1000 ? '₹${(v / 1000).toStringAsFixed(1)}k' : '₹${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medals = ['🥇', '🥈', '🥉'];
    final medal  = rank <= 3 ? medals[rank - 1] : '#$rank';

    // Watch live meeting for this worker (real-time from Firestore)
    final activeSession =
        ref.watch(workerSessionStreamProvider(summary.userId)).value;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkerReportPage(userId: summary.userId, workerName: summary.name),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: summary.wonLeads > 0 ? AppColors.primarySoft : AppColors.border),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Row(children: [
            // Rank + avatar
            Text(medal, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(
                summary.name.isNotEmpty ? summary.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
              )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(summary.name, style: const TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w800)),
                if (summary.email.isNotEmpty)
                  Text(summary.email, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
              ]),
            ),
            // Win rate badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
              child: Text('${summary.winRate.toStringAsFixed(0)}% win', style: const TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            const Icon(Symbols.arrow_forward_ios, color: AppColors.textLight, size: 14),
          ]),
          const SizedBox(height: 14),
          // Action buttons row: Assign Work + Meeting History
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showAssignTaskSheet(context, summary),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Symbols.assignment_add, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Assign Work', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MeetingHistoryPage(
                      userId: summary.userId,
                      workerName: summary.name,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primarySoft),
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Symbols.location_on, color: AppColors.primary, size: 16),
                    SizedBox(width: 6),
                    Text('Meetings', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          // ── Live Meeting Location ────────────────────────────────────────
          if (activeSession != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _LiveMeetingBadge(
                leadName: activeSession.leadName,
                lat: activeSession.lat,
                lng: activeSession.lng,
              ),
            ),
          // Stats row
          Row(children: [
            _statChip(Symbols.leaderboard, '${summary.leads.length} leads', AppColors.primary),
            const SizedBox(width: 8),
            _statChip(Symbols.emoji_events, '${summary.wonLeads} won', AppColors.warning),
            const SizedBox(width: 8),
            _statChip(Symbols.currency_rupee, _fmt(summary.revenue), AppColors.success),
            const SizedBox(width: 8),
            _statChip(Symbols.task_alt, '${summary.tasksCompleted}/${summary.tasks.length}', AppColors.primaryMid),
          ]),
        ]),
      ),
    );
  }

  void _showAssignTaskSheet(BuildContext context, WorkerSummary summary) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AssignTaskSheet(summary: summary),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 4 — All Clients
// ─────────────────────────────────────────────────────────────────────────────
class _AllClientsTab extends ConsumerStatefulWidget {
  const _AllClientsTab();
  @override
  ConsumerState<_AllClientsTab> createState() => _AllClientsTabState();
}

class _AllClientsTabState extends ConsumerState<_AllClientsTab> {
  String _statusFilter = 'All';

  static const _statusFilters = ['All', ...ClientStatus.all];
  static const _statusColors  = {
    'Active': AppColors.success, 'VIP': AppColors.warning,
    'Inactive': AppColors.danger, 'Completed': AppColors.primaryMid,
  };

  @override
  Widget build(BuildContext context) {
    final clientsAsync = ref.watch(adminAllClientsProvider);

    return clientsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
      error:   (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
      data: (clients) {
        final filtered = _statusFilter == 'All'
            ? clients : clients.where((c) => c.status == _statusFilter).toList();

        return Column(children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusFilters.map((s) {
                  final sel   = s == _statusFilter;
                  final color = _statusColors[s] ?? AppColors.primary;
                  return GestureDetector(
                    onTap: () => setState(() => _statusFilter = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel ? color : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? color : AppColors.border),
                      ),
                      child: Text(s, style: TextStyle(color: sel ? Colors.white : AppColors.textMid, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              Text('${filtered.length} clients', style: const TextStyle(color: AppColors.textMid, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No clients here', style: TextStyle(color: AppColors.textLight)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _ClientListTile(client: filtered[i]),
                  ),
          ),
        ]);
      },
    );
  }
}

class _ClientListTile extends ConsumerWidget {
  final ClientModel client;
  const _ClientListTile({required this.client});

  static const _statusColors = {
    'Active': AppColors.success, 'VIP': AppColors.warning,
    'Inactive': AppColors.danger, 'Completed': AppColors.primaryMid,
  };
  static const _statuses = ClientStatus.all;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _statusColors[client.status] ?? AppColors.primaryMid;
    final val   = client.monthlyValue != null
        ? (client.monthlyValue! >= 1000
            ? '₹${(client.monthlyValue! / 1000).toStringAsFixed(1)}k/mo'
            : '₹${client.monthlyValue!.toStringAsFixed(0)}/mo')
        : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
          child: Center(child: Text(
            client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800),
          )),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(client.name, style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w700)),
            if (client.companyName?.isNotEmpty == true)
              Text(client.companyName!, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
            if (client.assignTo?.isNotEmpty == true)
              Text('Worker: ${client.assignTo}', style: const TextStyle(color: AppColors.textMid, fontSize: 11)),
          ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(val, style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          // Status dropdown
          GestureDetector(
            onTap: () => _showStatusPicker(context, ref, client),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(client.status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(width: 3),
                Icon(Icons.arrow_drop_down, color: color, size: 14),
              ]),
            ),
          ),
        ]),
      ]),
    );
  }

  void _showStatusPicker(BuildContext context, WidgetRef ref, ClientModel client) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const Text('Change Client Status', style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ..._statuses.map((s) {
            final col        = _statusColors[s] ?? AppColors.primaryMid;
            final isSelected = s == client.status;
            return GestureDetector(
              onTap: () {
                Navigator.pop(context);
                if (client.id != null) {
                  ref.read(adminActionsProvider.notifier).changeClientStatus(client.id!, s);
                }
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? col.withValues(alpha: 0.12) : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? col : AppColors.border),
                ),
                child: Row(children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Text(s, style: TextStyle(color: col, fontWeight: FontWeight.w600, fontSize: 14)),
                  const Spacer(),
                  if (isSelected) Icon(Icons.check, color: col, size: 18),
                ]),
              ),
            );
          }),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 5 — Users / Admin Management
// ─────────────────────────────────────────────────────────────────────────────
class _UsersTab extends ConsumerWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return usersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
      error:   (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
      data: (users) {
        final admins  = users.where((u) => u.isAdmin).toList();
        final regular = users.where((u) => !u.isAdmin).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            const _CreateUserButton(),
            const SizedBox(height: 24),

            _SectionLabel('👑  Admin Accounts (${admins.length})'),
            const SizedBox(height: 12),
            if (admins.isEmpty)
              _emptyHint('No admins yet')
            else
              ...admins.map((u) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _UserTile(user: u),
              )),

            const SizedBox(height: 24),

            _SectionLabel('👤  Workers (${regular.length})'),
            const SizedBox(height: 12),
            if (regular.isEmpty)
              _emptyHint('No workers registered')
            else
              ...regular.map((u) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _UserTile(user: u),
              )),
          ],
        );
      },
    );
  }

  Widget _emptyHint(String msg) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Center(child: Text(msg, style: const TextStyle(color: AppColors.textLight, fontSize: 14))),
  );
}

// ── User tile — tappable → opens WorkerReportPage for non-admins ──────────────
class _UserTile extends ConsumerWidget {
  final UserModel user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = FirebaseAuth.instance.currentUser;

    return GestureDetector(
      onTap: user.isAdmin ? null : () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkerReportPage(
            userId: user.uid,
            workerName: user.name?.isNotEmpty == true ? user.name! : user.email,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: user.isAdmin ? AppColors.primarySoft : AppColors.border),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: user.isAdmin ? AppColors.primaryLight : AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(
              ((user.name?.isNotEmpty == true ? user.name! : user.email)[0]).toUpperCase(),
              style: TextStyle(color: user.isAdmin ? AppColors.primary : AppColors.textMid, fontSize: 18, fontWeight: FontWeight.w800),
            )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user.name?.isNotEmpty == true ? user.name! : 'No name',
                  style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(user.email, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
              if (user.isAdmin)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Admin', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
            ]),
          ),
          // View report arrow for workers
          if (!user.isAdmin) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Symbols.bar_chart, color: AppColors.primary, size: 14),
                SizedBox(width: 4),
                Text('Report', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(width: 8),
          ],
          // Promote/demote toggle (can't demote yourself)
          if (user.uid != me?.uid) _RoleToggle(uid: user.uid, isAdmin: user.isAdmin),
        ]),
      ),
    );
  }
}

class _RoleToggle extends ConsumerWidget {
  final String uid;
  final bool isAdmin;
  const _RoleToggle({required this.uid, required this.isAdmin});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifierState = ref.watch(adminUserProvider);
    final isBusy = notifierState is AsyncLoading;

    return GestureDetector(
      onTap: isBusy ? null : () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(isAdmin ? 'Remove admin?' : 'Make admin?',
                style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
            content: Text(
              isAdmin ? 'This user will lose admin access.' : 'This user will get full admin dashboard access.',
              style: const TextStyle(color: AppColors.textMid),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textMid))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAdmin ? AppColors.danger : AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(isAdmin ? 'Remove' : 'Promote', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await ref.read(adminUserProvider.notifier).toggleAdmin(uid, isAdmin: !isAdmin);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isAdmin ? AppColors.dangerLight : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isAdmin ? AppColors.danger.withValues(alpha: 0.3) : AppColors.primarySoft),
        ),
        child: Text(
          isAdmin ? 'Demote' : 'Promote',
          style: TextStyle(color: isAdmin ? AppColors.danger : AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Create New User button & sheet ───────────────────────────────────────────
class _CreateUserButton extends ConsumerWidget {
  const _CreateUserButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showCreateSheet(context, ref),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.person_add, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Create New User', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateUserSheet(parentRef: ref),
    );
  }
}

class _CreateUserSheet extends ConsumerStatefulWidget {
  final WidgetRef parentRef;
  const _CreateUserSheet({required this.parentRef});
  @override
  ConsumerState<_CreateUserSheet> createState() => _CreateUserSheetState();
}

class _CreateUserSheetState extends ConsumerState<_CreateUserSheet> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  bool _isAdmin = false;

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _create() async {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) { setState(() => _error = 'All fields are required.'); return; }
    if (pass.length < 6) { setState(() => _error = 'Password must be at least 6 characters.'); return; }

    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(adminUserProvider.notifier).createUserAccount(
        email: email, password: pass, name: name, isAdmin: _isAdmin,
      );
      if (!mounted) return;
      Navigator.pop(context);
      final role = _isAdmin ? 'Admin' : 'Worker';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$role account created for $email'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(
            width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          )),
          const Text('Create User Account', style: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Create a worker or manager account.', style: TextStyle(color: AppColors.textMid, fontSize: 13)),
          const SizedBox(height: 20),

          // Role selection
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isAdmin = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isAdmin ? AppColors.primaryLight : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: !_isAdmin ? AppColors.primary : AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text('Worker', style: TextStyle(color: !_isAdmin ? AppColors.primary : AppColors.textMid, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isAdmin = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isAdmin ? AppColors.primaryLight : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _isAdmin ? AppColors.primary : AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text('Manager', style: TextStyle(color: _isAdmin ? AppColors.primary : AppColors.textMid, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _field(_nameCtrl,  'Full Name',      Symbols.person),
          const SizedBox(height: 14),
          _field(_emailCtrl, 'Email address',  Symbols.mail, type: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _field(_passCtrl,  'Password',       Symbols.lock, obscure: _obscure,
            suffix: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textLight, size: 20),
              onPressed: () => setState(() => _obscure = !_obscure),
            )),

          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(10)),
              child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            ),
          ],
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity, height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: ElevatedButton(
                onPressed: _loading ? null : _create,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create Account', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {bool obscure = false, Widget? suffix, TextInputType? type}) =>
      TextField(
        controller: ctrl, obscureText: obscure, keyboardType: type,
        style: const TextStyle(color: AppColors.textDark, fontSize: 15),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: AppColors.textLight),
          prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
          suffixIcon: suffix,
          filled: true, fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Assign Task Sheet (admin → worker)
// ─────────────────────────────────────────────────────────────────────────────
class _AssignTaskSheet extends ConsumerStatefulWidget {
  final WorkerSummary summary;
  const _AssignTaskSheet({required this.summary});
  @override
  ConsumerState<_AssignTaskSheet> createState() => _AssignTaskSheetState();
}

class _AssignTaskSheetState extends ConsumerState<_AssignTaskSheet> {
  final _titleCtrl    = TextEditingController();
  final _notesCtrl    = TextEditingController();
  final _adminNoteCtrl = TextEditingController();
  String _priority    = 'Medium';
  DateTime _date      = DateTime.now().add(const Duration(days: 1));
  bool _loading       = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose(); _notesCtrl.dispose(); _adminNoteCtrl.dispose();
    super.dispose();
  }

  Future<void> _assign() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Task title is required'); return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(adminActionsProvider.notifier).assignTaskToWorker(
        workerUid: widget.summary.userId,
        title: _titleCtrl.text.trim(),
        priority: _priority,
        scheduledAt: _date,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        adminNote: _adminNoteCtrl.text.trim().isEmpty ? null : _adminNoteCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Work assigned to ${widget.summary.name}'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _pickDate(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 280,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Select Due Date', style: TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w700)),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: const Text('Done', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
          Expanded(child: CupertinoTheme(
            data: const CupertinoThemeData(primaryColor: AppColors.primary),
            child: CupertinoDatePicker(
              initialDateTime: _date,
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (d) => setState(() => _date = d),
            ),
          )),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, d MMM yyyy').format(_date);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(
              width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            )),
            // Header
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(
                  widget.summary.name.isNotEmpty ? widget.summary.name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                )),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Assign Work', style: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w800)),
                Text('To: ${widget.summary.name}', style: const TextStyle(color: AppColors.textMid, fontSize: 13)),
              ]),
            ]),
            const SizedBox(height: 24),

            // Task title
            _sheetLabel('Task Title *'),
            _sheetField(_titleCtrl, 'e.g. Follow up with ABC client', Symbols.task_alt),
            const SizedBox(height: 14),

            // Due date
            _sheetLabel('Due Date'),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(children: [
                  const Icon(Symbols.calendar_month, color: AppColors.textLight, size: 18),
                  const SizedBox(width: 10),
                  Text(dateStr, style: const TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const Icon(Symbols.chevron_right, color: AppColors.textLight, size: 18),
                ]),
              ),
            ),
            const SizedBox(height: 14),

            // Priority
            _sheetLabel('Priority'),
            Row(children: [
              _priorityChip('High', AppColors.danger),
              const SizedBox(width: 8),
              _priorityChip('Medium', AppColors.warning),
              const SizedBox(width: 8),
              _priorityChip('Low', AppColors.primary),
            ]),
            const SizedBox(height: 14),

            // Notes
            _sheetLabel('Task Details (optional)'),
            _sheetField(_notesCtrl, 'Describe what needs to be done...', Symbols.description, maxLines: 3),
            const SizedBox(height: 14),

            // Admin note (private)
            _sheetLabel('Note to Worker (optional)'),
            _sheetField(_adminNoteCtrl, 'Any extra instructions for them...', Symbols.sticky_note_2),
            const SizedBox(height: 8),

            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(10)),
                child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity, height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _assign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Assign Work', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _sheetLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
  );

  Widget _sheetField(TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1}) =>
      TextField(
        controller: ctrl, maxLines: maxLines,
        style: const TextStyle(color: AppColors.textDark, fontSize: 15),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hint, hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
          prefixIcon: maxLines == 1 ? Icon(icon, color: AppColors.textLight, size: 18) : null,
          filled: true, fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      );

  Widget _priorityChip(String label, Color color) {
    final isSel = _priority == label;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _priority = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSel ? color.withValues(alpha: 0.12) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSel ? color : AppColors.border, width: isSel ? 1.5 : 1),
        ),
        child: Center(child: Text(label, style: TextStyle(
          color: isSel ? color : AppColors.textMid,
          fontSize: 12, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
        ))),
      ),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 6 — Announcements / Notices
// ─────────────────────────────────────────────────────────────────────────────
class _AnnouncementsTab extends ConsumerWidget {
  const _AnnouncementsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anAsync = ref.watch(announcementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPostSheet(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Symbols.campaign, color: Colors.white),
        label: const Text('New Notice', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      body: anAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
        data: (list) {
          if (list.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Symbols.campaign, color: AppColors.primary, size: 34),
              ),
              const SizedBox(height: 16),
              const Text('No notices yet', style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Tap + New Notice to post one to all workers', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
            ]));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _AnnouncementCard(item: list[i], ref: ref),
          );
        },
      ),
    );
  }

  void _showPostSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PostAnnouncementSheet(parentRef: ref),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementModel item;
  final WidgetRef ref;
  const _AnnouncementCard({required this.item, required this.ref});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _ago(item.createdAt);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: item.isPinned ? AppColors.primarySoft : AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.07), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (item.isPinned) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Symbols.push_pin, color: AppColors.primary, size: 11),
                SizedBox(width: 4),
                Text('Pinned', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(item.title, style: const TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.w800))),
          // Pin toggle
          GestureDetector(
            onTap: () => ref.read(announcementNotifierProvider.notifier).togglePin(item.id!, !item.isPinned),
            child: Icon(item.isPinned ? Symbols.push_pin : Symbols.push_pin,
                color: item.isPinned ? AppColors.primary : AppColors.textLight, size: 18),
          ),
          const SizedBox(width: 10),
          // Delete
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: const Icon(Symbols.delete_outline, color: AppColors.danger, size: 18),
          ),
        ]),
        const SizedBox(height: 10),
        Text(item.body, style: const TextStyle(color: AppColors.textMid, fontSize: 14, height: 1.5)),
        const SizedBox(height: 12),
        Row(children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(
              item.adminName.isNotEmpty ? item.adminName[0].toUpperCase() : 'M',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
            )),
          ),
          const SizedBox(width: 8),
          Text('${item.adminName} · $timeAgo', style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
        ]),
      ]),
    );
  }

  String _ago(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete notice?', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700)),
        content: const Text('This notice will be removed for all workers.', style: TextStyle(color: AppColors.textMid)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.textMid))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context);
              ref.read(announcementNotifierProvider.notifier).delete(item.id!);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _PostAnnouncementSheet extends ConsumerStatefulWidget {
  final WidgetRef parentRef;
  const _PostAnnouncementSheet({required this.parentRef});
  @override
  ConsumerState<_PostAnnouncementSheet> createState() => _PostAnnouncementSheetState();
}

class _PostAnnouncementSheetState extends ConsumerState<_PostAnnouncementSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();
  bool _pinned  = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _titleCtrl.dispose(); _bodyCtrl.dispose(); super.dispose(); }

  Future<void> _post() async {
    if (_titleCtrl.text.trim().isEmpty || _bodyCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Title and message are required'); return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      await ref.read(announcementNotifierProvider.notifier).post(
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
        adminUid: user?.uid ?? '',
        adminName: user?.displayName ?? user?.email?.split('@').first ?? 'Manager',
        pinned: _pinned,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Notice posted to all workers'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(
            width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          )),
          const Text('Post a Notice', style: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Visible to all workers on their home screen', style: TextStyle(color: AppColors.textMid, fontSize: 13)),
          const SizedBox(height: 20),

          _label('Title'),
          _field(_titleCtrl, 'e.g. Team meeting at 3pm', Symbols.campaign),
          const SizedBox(height: 14),

          _label('Message'),
          TextField(
            controller: _bodyCtrl, maxLines: 4,
            style: const TextStyle(color: AppColors.textDark, fontSize: 14),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: 'Write the notice details here...',
              hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
              filled: true, fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 14),

          // Pin toggle
          GestureDetector(
            onTap: () => setState(() => _pinned = !_pinned),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _pinned ? AppColors.primaryLight : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _pinned ? AppColors.primarySoft : AppColors.border),
              ),
              child: Row(children: [
                Icon(Symbols.push_pin, color: _pinned ? AppColors.primary : AppColors.textLight, size: 18),
                const SizedBox(width: 10),
                Text('Pin to top', style: TextStyle(
                  color: _pinned ? AppColors.primary : AppColors.textMid,
                  fontSize: 14, fontWeight: FontWeight.w600,
                )),
                const Spacer(),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44, height: 24,
                  decoration: BoxDecoration(
                    color: _pinned ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: _pinned ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 20, height: 20,
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                  ),
                ),
              ]),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(10)),
              child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
            ),
          ],
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity, height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: ElevatedButton(
                onPressed: _loading ? null : _post,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Post Notice', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(color: AppColors.textMid, fontSize: 12, fontWeight: FontWeight.w600)),
  );

  Widget _field(TextEditingController ctrl, String hint, IconData icon) => TextField(
    controller: ctrl,
    style: const TextStyle(color: AppColors.textDark, fontSize: 15),
    cursorColor: AppColors.primary,
    decoration: InputDecoration(
      hintText: hint, hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.textLight, size: 18),
      filled: true, fillColor: AppColors.background,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Live Meeting Badge  (Admin side — shown inside WorkerCard)
// ─────────────────────────────────────────────────────────────────────────────
class _LiveMeetingBadge extends StatelessWidget {
  final String leadName;
  final double? lat;
  final double? lng;
  const _LiveMeetingBadge(
      {required this.leadName, required this.lat, required this.lng});

  Future<void> _openMap() async {
    if (lat == null || lng == null) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF7D).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF4CAF7D).withValues(alpha: 0.35)),
      ),
      child: Row(children: [
        // Pulsing dot
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFF4CAF7D),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              '🟢 LIVE — In Meeting',
              style: TextStyle(
                color: Color(0xFF4CAF7D),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Client: $leadName',
              style: const TextStyle(
                  color: AppColors.textMid,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ]),
        ),
        // View Location button
        if (lat != null && lng != null)
          GestureDetector(
            onTap: _openMap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 13),
                  SizedBox(width: 5),
                  Text(
                    'View Location',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 7 — Attendance  (admin view of all employees)
// ─────────────────────────────────────────────────────────────────────────────
class _AttendanceTab extends ConsumerStatefulWidget {
  const _AttendanceTab();
  @override
  ConsumerState<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<_AttendanceTab> {
  DateTime _selectedDate = DateTime.now();

  String get _dateKey {
    final d = _selectedDate;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  bool get _isToday {
    final n = DateTime.now();
    return _selectedDate.year  == n.year &&
           _selectedDate.month == n.month &&
           _selectedDate.day   == n.day;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.textDark,
          ),
          dialogBackgroundColor: AppColors.surface,
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(dateAttendanceProvider(_dateKey));
    final allUsersAsync = ref.watch(allUsersProvider);

    return Column(
      children: [
        // ── Date selector bar ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          color: AppColors.background,
          child: Row(children: [
            // Back day
            _navBtn(Icons.chevron_left_rounded, () {
              setState(() => _selectedDate =
                  _selectedDate.subtract(const Duration(days: 1)));
            }),
            const SizedBox(width: 10),
            // Date display — tappable
            Expanded(
              child: GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [BoxShadow(
                        color: AppColors.primary.withOpacity(0.06),
                        blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _isToday
                          ? 'Today, ${DateFormat('d MMMM').format(_selectedDate)}'
                          : DateFormat('EEE, d MMMM yyyy').format(_selectedDate),
                      style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Forward day (only if not today)
            _navBtn(
              Icons.chevron_right_rounded,
              _isToday
                  ? null
                  : () => setState(() => _selectedDate =
                      _selectedDate.add(const Duration(days: 1))),
            ),
          ]),
        ),

        // ── Summary row ────────────────────────────────────────────────────
        recordsAsync.when(
          loading: () => const SizedBox.shrink(),
          error:   (_, __) => const SizedBox.shrink(),
          data: (records) => allUsersAsync.when(
            loading: () => const SizedBox.shrink(),
            error:   (_, __) => const SizedBox.shrink(),
            data: (users) {
              final totalEmployees = users.where((u) => !u.isAdmin).length;
              final checkedIn      = records.length;
              final checkedOut     = records.where((r) => r.hasCheckedOut).length;
              final absent         = totalEmployees - checkedIn;
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(children: [
                  _summaryChip('$checkedIn',   'Present',  AppColors.success),
                  const SizedBox(width: 8),
                  _summaryChip('$checkedOut',  'Left',     AppColors.primaryMid),
                  const SizedBox(width: 8),
                  _summaryChip(absent < 0 ? '—' : '$absent', 'Absent', AppColors.danger),
                ]),
              );
            },
          ),
        ),

        // ── Records list ───────────────────────────────────────────────────
        Expanded(
          child: recordsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2)),
            error:   (e, _) => Center(child: Text('$e',
                style: const TextStyle(color: AppColors.danger))),
            data: (records) {
              if (records.isEmpty) {
                return Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Icon(Symbols.how_to_reg,
                          color: AppColors.primary, size: 34),
                    ),
                    const SizedBox(height: 16),
                    const Text('No attendance records',
                        style: TextStyle(color: AppColors.textDark,
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text('Nobody has checked in for this date.',
                        style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                  ]),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                itemCount: records.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _AdminAttendanceTile(record: records[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _navBtn(IconData icon, VoidCallback? onTap) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: onTap == null ? AppColors.background : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon,
          color: onTap == null ? AppColors.textLight : AppColors.textDark,
          size: 22),
    ),
  );

  Widget _summaryChip(String value, String label, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

// ── Admin attendance tile ─────────────────────────────────────────────────────
class _AdminAttendanceTile extends StatelessWidget {
  final AttendanceModel record;
  const _AdminAttendanceTile({required this.record});

  static final _timeFmt = DateFormat('h:mm a');

  Future<void> _openMap() async {
    if (!record.hasLocation) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${record.lat},${record.lng}');
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = !record.hasCheckedOut;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppColors.success.withOpacity(0.4)
              : AppColors.border,
        ),
        boxShadow: [BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        // Avatar
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.primaryGradient : null,
            color: isActive ? null : AppColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(child: Text(
            record.userName.isNotEmpty ? record.userName[0].toUpperCase() : '?',
            style: TextStyle(
                color: isActive ? Colors.white : AppColors.textMid,
                fontSize: 18, fontWeight: FontWeight.w800),
          )),
        ),
        const SizedBox(width: 12),

        // Info
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(record.userName,
                style: const TextStyle(color: AppColors.textDark,
                    fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(width: 6),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('IN OFFICE',
                    style: TextStyle(color: AppColors.success,
                        fontSize: 9, fontWeight: FontWeight.w800)),
              ),
          ]),
          const SizedBox(height: 3),
          Text(record.userEmail,
              style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.login_rounded, size: 11, color: AppColors.success),
            const SizedBox(width: 3),
            Text(_timeFmt.format(record.checkInTime),
                style: const TextStyle(color: AppColors.textMid, fontSize: 11)),
            if (record.hasCheckedOut) ...[
              const SizedBox(width: 8),
              Icon(Icons.logout_rounded, size: 11, color: AppColors.danger),
              const SizedBox(width: 3),
              Text(_timeFmt.format(record.checkOutTime!),
                  style: const TextStyle(color: AppColors.textMid, fontSize: 11)),
              const SizedBox(width: 8),
              Text('· ${record.durationLabel}',
                  style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ]),
        ])),

        // Location button
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (record.hasLocation)
            GestureDetector(
              onTap: _openMap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.location_on, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text('View Location',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ]),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.location_off_rounded, color: AppColors.textLight, size: 12),
                SizedBox(width: 4),
                Text('No GPS', style: TextStyle(color: AppColors.textLight, fontSize: 10)),
              ]),
            ),
        ]),
      ]),
    );
  }
}
