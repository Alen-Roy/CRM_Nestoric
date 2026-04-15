import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/features/admin/viewmodels/admin_viewmodel.dart';
import 'package:crm/features/auth/pages/login_page.dart';
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
// Admin Dashboard Page
// ─────────────────────────────────────────────────────────────────────────────
class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  // 0 = Overview, 1 = Leads, 2 = Users

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
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
          // ── Hero Header ───────────────────────────────────────────────────
          _AdminHeader(name: name, onLogout: _logout),

          // ── Tab Bar ───────────────────────────────────────────────────────
          _AdminTabBar(controller: _tabs),

          // ── Tab content ────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _OverviewTab(),
                _AllLeadsTab(),
                _UsersTab(),
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
                  // Admin badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Symbols.shield_person,
                            color: Colors.white, size: 14),
                        SizedBox(width: 5),
                        Text('Manager',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Logout
                  GestureDetector(
                    onTap: onLogout,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Symbols.logout,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Welcome, $name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Tab Bar
// ─────────────────────────────────────────────────────────────────────────────
class _AdminTabBar extends StatelessWidget {
  final TabController controller;
  const _AdminTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final labels = ['Overview', 'All Leads', 'Users'];
    final icons  = [Symbols.dashboard, Symbols.leaderboard, Symbols.group];

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: List.generate(3, (i) {
          final selected = controller.index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.animateTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                padding:
                    const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icons[i],
                        color: selected ? Colors.white : AppColors.textMid,
                        size: 18),
                    const SizedBox(height: 3),
                    Text(labels[i],
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.textMid,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — Overview
// ─────────────────────────────────────────────────────────────────────────────
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync      = ref.watch(adminStatsProvider);
    final leadsAsync      = ref.watch(adminAllLeadsProvider);
    final leaderAsync     = ref.watch(adminLeaderboardProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        // ── KPI Grid ─────────────────────────────────────────────────────
        statsAsync.when(
          loading: () => _loadingCard(),
          error: (e, _) => _errorCard('$e'),
          data: (s) => _KpiGrid(stats: s),
        ),
        const SizedBox(height: 24),

        // ── Pipeline bar ─────────────────────────────────────────────────
        leadsAsync.when(
          loading: () => _loadingCard(),
          error: (e, _) => _errorCard('$e'),
          data: (leads) => leads.isEmpty
              ? const SizedBox.shrink()
              : _PipelineCard(leads: leads),
        ),
        const SizedBox(height: 24),

        // ── Leaderboard ────────────────────────────────────────────────
        const _SectionLabel('🏆  Leaderboard'),
        const SizedBox(height: 12),
        leaderAsync.when(
          loading: () => _loadingCard(),
          error: (e, _) => _errorCard('$e'),
          data: (entries) => entries.isEmpty
              ? _emptyCard('No leads yet')
              : _LeaderboardCard(entries: entries),
        ),
      ],
    );
  }

  Widget _loadingCard() => Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary, strokeWidth: 2),
        ),
      );

  Widget _errorCard(String msg) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.dangerLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(msg,
            style: const TextStyle(color: AppColors.danger, fontSize: 13)),
      );

  Widget _emptyCard(String msg) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
            child: Text(msg,
                style: const TextStyle(
                    color: AppColors.textLight, fontSize: 14))),
      );
}

// ── KPI Grid ──────────────────────────────────────────────────────────────────
class _KpiGrid extends StatelessWidget {
  final AdminStats stats;
  const _KpiGrid({required this.stats});

  String _fmt(double v) => v >= 1000
      ? '₹${(v / 1000).toStringAsFixed(1)}k'
      : '₹${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiData(
        icon: Symbols.currency_rupee,
        label: 'Total Revenue',
        value: _fmt(stats.totalRevenue),
        color: AppColors.primary,
      ),
      _KpiData(
        icon: Symbols.person_add,
        label: 'Total Leads',
        value: '${stats.totalLeads}',
        color: AppColors.primaryGlow,
      ),
      _KpiData(
        icon: Symbols.business,
        label: 'Clients',
        value: '${stats.totalClients}',
        color: AppColors.primaryMid,
      ),
      _KpiData(
        icon: Symbols.trending_up,
        label: 'Win Rate',
        value: '${stats.winRate.toStringAsFixed(0)}%',
        color: AppColors.success,
      ),
      _KpiData(
        icon: Symbols.emoji_events,
        label: 'Won Deals',
        value: '${stats.dealsWon}',
        color: AppColors.warning,
      ),
      _KpiData(
        icon: Symbols.group,
        label: 'Team Size',
        value: '${stats.totalUsers}',
        color: AppColors.primaryGlow,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.95,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: cards.length,
      itemBuilder: (_, i) => _KpiCard(data: cards[i]),
    );
  }
}

class _KpiData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _KpiData(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.value,
                  style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              Text(data.label,
                  style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Pipeline card ─────────────────────────────────────────────────────────────
class _PipelineCard extends StatelessWidget {
  final List<LeadModel> leads;
  const _PipelineCard({required this.leads});

  static const _stages = ['New', 'Proposal', 'Negotiation', 'Won', 'Lost'];
  static const _colors = {
    'New': AppColors.primaryGlow,
    'Proposal': AppColors.primaryMid,
    'Negotiation': AppColors.primary,
    'Won': AppColors.success,
    'Lost': AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final l in leads) counts[l.stage] = (counts[l.stage] ?? 0) + 1;
    final total = leads.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Pipeline — All Teams',
                  style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
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
                final frac = c / total;
                return Expanded(
                  flex: (frac * 100).round().clamp(1, 100),
                  child: Container(
                      height: 12, color: _colors[s] ?? AppColors.primaryMid),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _stages.where((s) => (counts[s] ?? 0) > 0).map((s) {
              final color = _colors[s] ?? AppColors.primaryMid;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 5),
                  Text('$s (${counts[s]})',
                      style: const TextStyle(
                          color: AppColors.textMid,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _pill(String t) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(t,
            style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      );
}

// ── Leaderboard Card ──────────────────────────────────────────────────────────
class _LeaderboardCard extends StatelessWidget {
  final List<LeaderEntry> entries;
  const _LeaderboardCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    final shown = entries.take(8).toList();
    final medals = ['🥇', '🥈', '🥉'];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: shown.asMap().entries.map((e) {
          final idx   = e.key;
          final entry = e.value;
          final isLast = idx == shown.length - 1;
          final medal = idx < 3 ? medals[idx] : '${idx + 1}';
          final revStr = entry.revenue >= 1000
              ? '₹${(entry.revenue / 1000).toStringAsFixed(1)}k'
              : '₹${entry.revenue.toStringAsFixed(0)}';

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(medal,
                          style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 10),
                    // Avatar
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          (entry.name.isNotEmpty
                                  ? entry.name[0]
                                  : '?')
                              .toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.name,
                              style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          Text(
                              '${entry.wonCount} won / ${entry.totalLeads} leads',
                              style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(revStr,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(color: AppColors.border, height: 1),
            ],
          );
        }).toList(),
      ),
    );
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

  static const _stageFilters = [
    'All', 'New', 'Proposal', 'Negotiation', 'Won', 'Lost'
  ];
  static const _stageColors = {
    'New': AppColors.primaryGlow,
    'Proposal': AppColors.primaryMid,
    'Negotiation': AppColors.primary,
    'Won': AppColors.success,
    'Lost': AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(adminAllLeadsProvider);

    return leadsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2)),
      error: (e, _) =>
          Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
      data: (leads) {
        final filtered = _stageFilter == 'All'
            ? leads
            : leads.where((l) => l.stage == _stageFilter).toList();

        return Column(
          children: [
            // ── Filter chips ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _stageFilters.map((s) {
                    final sel = s == _stageFilter;
                    final color =
                        _stageColors[s] ?? AppColors.primary;
                    return GestureDetector(
                      onTap: () => setState(() => _stageFilter = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel
                              ? color
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: sel ? color : AppColors.border),
                        ),
                        child: Text(s,
                            style: TextStyle(
                              color:
                                  sel ? Colors.white : AppColors.textMid,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // ── Count label ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Text('${filtered.length} leads',
                      style: const TextStyle(
                          color: AppColors.textMid,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            // ── List ──────────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No leads in this stage',
                          style: TextStyle(color: AppColors.textLight)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) =>
                          _LeadListTile(lead: filtered[i]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _LeadListTile extends StatelessWidget {
  final LeadModel lead;
  const _LeadListTile({required this.lead});

  static const _stageColors = {
    'New': AppColors.primaryGlow,
    'Proposal': AppColors.primaryMid,
    'Negotiation': AppColors.primary,
    'Won': AppColors.success,
    'Lost': AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final stageColor = _stageColors[lead.stage] ?? AppColors.primaryMid;
    final amountStr = lead.amount != null && lead.amount!.isNotEmpty
        ? '₹${lead.amount}'
        : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: stageColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                style: TextStyle(
                    color: stageColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lead.name,
                    style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(lead.companyName ?? lead.phone,
                    style: const TextStyle(
                        color: AppColors.textLight, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right side: amount + stage
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amountStr,
                  style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: stageColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(lead.stage,
                    style: TextStyle(
                        color: stageColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 — Users / Admin Management
// ─────────────────────────────────────────────────────────────────────────────
class _UsersTab extends ConsumerWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return usersAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2)),
      error: (e, _) =>
          Center(child: Text('$e', style: const TextStyle(color: AppColors.danger))),
      data: (users) {
        final admins  = users.where((u) => u.isAdmin).toList();
        final regular = users.where((u) => !u.isAdmin).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            // ── Create Admin button ─────────────────────────────────
            _CreateAdminButton(),
            const SizedBox(height: 24),

            // ── Admin users ─────────────────────────────────────────
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

            // ── Regular users ───────────────────────────────────────
            _SectionLabel('👤  Regular Users (${regular.length})'),
            const SizedBox(height: 12),
            if (regular.isEmpty)
              _emptyHint('No regular users')
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
        child: Center(
            child: Text(msg,
                style: const TextStyle(
                    color: AppColors.textLight, fontSize: 14))),
      );
}

// ── User tile with promote/demote toggle ──────────────────────────────────────
class _UserTile extends ConsumerWidget {
  final UserModel user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = FirebaseAuth.instance.currentUser;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: user.isAdmin ? AppColors.primarySoft : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: user.isAdmin
                  ? AppColors.primaryLight
                  : AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                ((user.name?.isNotEmpty == true ? user.name! : user.email)[0])
                    .toUpperCase(),
                style: TextStyle(
                    color: user.isAdmin
                        ? AppColors.primary
                        : AppColors.textMid,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name?.isNotEmpty == true ? user.name! : 'No name',
                  style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(user.email,
                    style: const TextStyle(
                        color: AppColors.textLight, fontSize: 12)),
                if (user.isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Admin',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
          // Toggle (can't demote yourself)
          if (user.uid != me?.uid)
            _RoleToggle(uid: user.uid, isAdmin: user.isAdmin),
        ],
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
      onTap: isBusy
          ? null
          : () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text(
                    isAdmin ? 'Remove admin?' : 'Make admin?',
                    style: const TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700),
                  ),
                  content: Text(
                    isAdmin
                        ? 'This user will lose admin access.'
                        : 'This user will get full admin dashboard access.',
                    style: const TextStyle(color: AppColors.textMid),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel',
                            style:
                                TextStyle(color: AppColors.textMid))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAdmin
                            ? AppColors.danger
                            : AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(isAdmin ? 'Remove' : 'Promote',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref
                    .read(adminUserProvider.notifier)
                    .toggleAdmin(uid, isAdmin: !isAdmin);
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isAdmin
              ? AppColors.dangerLight
              : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isAdmin
                  ? AppColors.danger.withValues(alpha: 0.3)
                  : AppColors.primarySoft),
        ),
        child: Text(
          isAdmin ? 'Demote' : 'Promote',
          style: TextStyle(
              color: isAdmin ? AppColors.danger : AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Create New Admin button & bottom sheet ─────────────────────────────────────
class _CreateAdminButton extends ConsumerWidget {
  const _CreateAdminButton();

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
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.person_add, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Create New Admin Account',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
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
      builder: (_) => _CreateAdminSheet(parentRef: ref),
    );
  }
}

class _CreateAdminSheet extends ConsumerStatefulWidget {
  final WidgetRef parentRef;
  const _CreateAdminSheet({required this.parentRef});
  @override
  ConsumerState<_CreateAdminSheet> createState() => _CreateAdminSheetState();
}

class _CreateAdminSheetState extends ConsumerState<_CreateAdminSheet> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;
  bool _loading    = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'All fields are required.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(adminUserProvider.notifier).createAdmin(
            email: email,
            password: pass,
            name: name,
          );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Admin account created for $email'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Create Admin Account',
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('This user will have full manager access.',
                style:
                    TextStyle(color: AppColors.textMid, fontSize: 13)),
            const SizedBox(height: 20),

            _field(_nameCtrl, 'Full Name', Symbols.person),
            const SizedBox(height: 14),
            _field(_emailCtrl, 'Email address', Symbols.mail,
                type: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _field(_passCtrl, 'Password', Symbols.lock,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textLight,
                      size: 20),
                  onPressed: () =>
                      setState(() => _obscure = !_obscure),
                )),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_error!,
                    style: const TextStyle(
                        color: AppColors.danger, fontSize: 13)),
              ),
            ],
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _create,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Create Admin',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool obscure = false,
    Widget? suffix,
    TextInputType? type,
  }) =>
      TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: type,
        style: const TextStyle(color: AppColors.textDark, fontSize: 15),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textLight),
          prefixIcon: Icon(icon, color: AppColors.textLight, size: 20),
          suffixIcon: suffix,
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      );
}
