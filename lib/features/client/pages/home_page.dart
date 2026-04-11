import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/core/widgets/follow_up_section.dart';
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

class RecentActivity {
  final IconData icon;
  final String title;
  final String time;
  const RecentActivity({required this.icon, required this.title, required this.time});
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
    case 'call': return '📞';
    case 'meeting': return '🤝';
    case 'email': return '📧';
    case 'proposal': return '📄';
    default: return '📝';
  }
}
String _typeLabel(String t) {
  switch (t) {
    case 'call': return 'Call';
    case 'meeting': return 'Meeting';
    case 'email': return 'Email';
    case 'proposal': return 'Proposal';
    default: return 'Note';
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

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  void showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync  = ref.watch(homeStatsProvider);
    final recentAsync = ref.watch(recentActivitiesProvider);
    final user        = FirebaseAuth.instance.currentUser;
    final userName    = user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final firstName   = userName.split(' ').first;

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
                    width: 44, height: 44,
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset('assets/logo/logo.png', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Hi $firstName', style: const TextStyle(color: AppColors.textMid, fontSize: 15, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  _iconBtn(Icons.search_rounded, () {}),
                  const SizedBox(width: 8),
                  _iconBtn(Symbols.notifications, () => ref.read(authProvider.notifier).logout()),
                ],
              ),
              const SizedBox(height: 20),
              // ── Big title ────────────────────────────────────────────────
              const Text('Your\nDashboard',
                  style: TextStyle(color: AppColors.textDark, fontSize: 38, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -0.5)),
              const SizedBox(height: 20),
              // ── Stat pills ───────────────────────────────────────────────
              statsAsync.when(
                data: (s) => _StatPillsRow(tasks: s.tasksToday, newLeads: s.totalLeads, dealsWon: s.dealsWon),
                loading: () => const _StatPillsRow(tasks: 0, newLeads: 0, dealsWon: 0),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              // ── Revenue card ─────────────────────────────────────────────
              statsAsync.when(
                data: (s) => _RevenueCard(revenue: s.totalRevenue, dealsWon: s.dealsWon, totalLeads: s.totalLeads),
                loading: () => const _RevenueCard(revenue: 0, dealsWon: 0, totalLeads: 0),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              // ── Quick actions ────────────────────────────────────────────
              const _SectionHeader(title: 'Quick Actions'),
              const SizedBox(height: 14),
              _QuickActionsGrid(actions: [
                _QAction(icon: Symbols.person_add,     label: 'Add Lead',    color: AppColors.primary,    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewLeadPage()))),
                _QAction(icon: Symbols.calendar_month, label: 'Schedule',    color: AppColors.secondary,  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskAddPage(selectedDate: DateTime.now())))),
                _QAction(icon: Symbols.call,           label: 'Call Client', color: AppColors.success,    onTap: () => _showCallClientSheet(context, ref)),
                _QAction(icon: Symbols.description,    label: 'Reports',     color: AppColors.accent3,    onTap: () => ref.read(currentTabProvider.notifier).state = 4),
              ]),
              const SizedBox(height: 24),
              // ── Follow-up ────────────────────────────────────────────────
              FollowUpSection(onSeeAll: () => ref.read(currentTabProvider.notifier).state = 1),
              const SizedBox(height: 24),
              // ── Recent activities ────────────────────────────────────────
              recentAsync.when(
                data: (a) => a.isEmpty ? const SizedBox.shrink() : _RecentActivitiesCard(activities: a),
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
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, color: AppColors.textDark, size: 20),
      ),
    );
  }
}

class _StatPillsRow extends StatelessWidget {
  final int tasks, newLeads, dealsWon;
  const _StatPillsRow({required this.tasks, required this.newLeads, required this.dealsWon});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _pill('${tasks.toString().padLeft(2, '0')} Tasks',  AppColors.cardDark,    Colors.white),
        const SizedBox(width: 10),
        _pill('${newLeads.toString().padLeft(2, '0')} Leads', AppColors.primaryLight, AppColors.primary),
        const SizedBox(width: 10),
        _pill('${dealsWon.toString().padLeft(2, '0')} Won',   AppColors.primary,     Colors.white),
      ]),
    );
  }
  Widget _pill(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(50)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 14, fontWeight: FontWeight.w700)),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final double revenue;
  final int dealsWon, totalLeads;
  const _RevenueCard({required this.revenue, required this.dealsWon, required this.totalLeads});
  @override
  Widget build(BuildContext context) {
    final revenueStr = revenue >= 1000 ? '₹${(revenue / 1000).toStringAsFixed(1)}k' : '₹${revenue.toStringAsFixed(0)}';
    final winRate = totalLeads == 0 ? 0 : (dealsWon / totalLeads * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Revenue Summary', style: TextStyle(color: AppColors.textMid, fontSize: 13, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                child: const Text('This Year', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(revenueStr, style: const TextStyle(color: AppColors.textDark, fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: -1)),
          const Text('Total from won deals', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
          const SizedBox(height: 18),
          Row(
            children: [
              _miniStat('$dealsWon', 'Won',      AppColors.success),
              const SizedBox(width: 10),
              _miniStat('$totalLeads', 'Leads',  AppColors.primary),
              const SizedBox(width: 10),
              _miniStat('$winRate%', 'Win Rate', AppColors.accent3),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: totalLeads == 0 ? 0 : (dealsWon / totalLeads).clamp(0.0, 1.0),
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
    );
  }
  Widget _miniStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
        ]),
      ),
    );
  }
  Widget _dot(Color c, String label) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
  ]);
}

class _QAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QAction({required this.icon, required this.label, required this.color, required this.onTap});
}

class _QuickActionsGrid extends StatelessWidget {
  final List<_QAction> actions;
  const _QuickActionsGrid({required this.actions});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) => GestureDetector(
        onTap: a.onTap,
        child: Column(children: [
          Container(
            width: 62, height: 62,
            decoration: BoxDecoration(color: a.color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Icon(a.icon, color: a.color, size: 26),
          ),
          const SizedBox(height: 7),
          Text(a.label, style: const TextStyle(color: AppColors.textMid, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ]),
      )).toList(),
    );
  }
}

class _RecentActivitiesCard extends StatelessWidget {
  final List<RecentActivity> activities;
  const _RecentActivitiesCard({required this.activities});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Activities', style: TextStyle(color: AppColors.textDark, fontSize: 17, fontWeight: FontWeight.w700)),
                const Text('See all', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...activities.asMap().entries.map((e) {
            final a = e.value;
            final isLast = e.key == activities.length - 1;
            return Column(children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                  child: Icon(a.icon, color: AppColors.primary, size: 18),
                ),
                title: Text(a.title, style: const TextStyle(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(a.time, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
              ),
              if (!isLast) const Divider(color: AppColors.divider, height: 1, indent: 72),
            ]);
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700));
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
      decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Icon(Symbols.call, color: AppColors.primary, size: 22),
              SizedBox(width: 10),
              Text('Call a Client', style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w700)),
            ])),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: (v) => setState(() => _search = v.toLowerCase()),
            style: const TextStyle(color: AppColors.textDark, fontSize: 14),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: 'Search clients…', hintStyle: const TextStyle(color: AppColors.textLight),
              prefixIcon: const Icon(Icons.search, color: AppColors.textLight, size: 20),
              filled: true, fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Divider(color: AppColors.border, height: 1),
        Expanded(child: clientsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
          error: (_, __) => const Center(child: Text('Failed to load clients.', style: TextStyle(color: AppColors.textLight))),
          data: (clients) {
            final filtered = _search.isEmpty ? clients
                : clients.where((c) => c.name.toLowerCase().contains(_search) || c.phone.contains(_search) || (c.companyName?.toLowerCase().contains(_search) ?? false)).toList();
            if (filtered.isEmpty) return Center(child: Text(clients.isEmpty ? 'No clients yet.' : 'No results found.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textLight, fontSize: 13)));
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1, indent: 72),
              itemBuilder: (ctx, i) => _ClientCallTile(client: filtered[i]),
            );
          },
        )),
      ]),
    );
  }
}

class _ClientCallTile extends StatelessWidget {
  final ClientModel client;
  const _ClientCallTile({required this.client});
  Future<void> _call(BuildContext context) async {
    final raw = client.phone.replaceAll(RegExp(r'[\s\-()]'), '');
    final uri = Uri.parse('tel:$raw');
    if (await canLaunchUrl(uri)) { await launchUrl(uri); }
    else {
      await Clipboard.setData(ClipboardData(text: client.phone));
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied: ${client.phone}'), behavior: SnackBarBehavior.floating));
    }
  }
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(backgroundColor: AppColors.primaryLight, child: Text(client.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
      title: Text(client.name, style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(client.phone, style: const TextStyle(color: AppColors.textMid, fontSize: 12)),
      trailing: GestureDetector(
        onTap: () => _call(context),
        child: Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Symbols.call, color: AppColors.success, size: 18)),
      ),
    );
  }
}
