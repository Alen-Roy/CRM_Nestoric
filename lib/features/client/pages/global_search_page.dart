import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/features/client/pages/client_detail_page.dart';
import 'package:crm/features/client/pages/lead_detail_page.dart';
import 'package:crm/models/client_model.dart';
import 'package:crm/models/lead_model.dart';
import 'package:crm/models/task_model.dart';
import 'package:crm/viewmodels/client_viewmodel.dart';
import 'package:crm/viewmodels/leads_viewmodel.dart';
import 'package:crm/viewmodels/task_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

// ── Result types ──────────────────────────────────────────────────────────────
sealed class _SearchResult {}

class _LeadResult extends _SearchResult {
  final LeadModel lead;
  _LeadResult(this.lead);
}

class _ClientResult extends _SearchResult {
  final ClientModel client;
  _ClientResult(this.client);
}

class _TaskResult extends _SearchResult {
  final TaskModel task;
  _TaskResult(this.task);
}

// ── Search logic ──────────────────────────────────────────────────────────────
class _SearchResults {
  final List<LeadModel>   leads;
  final List<ClientModel> clients;
  final List<TaskModel>   tasks;
  final String            query;

  const _SearchResults({
    required this.leads,
    required this.clients,
    required this.tasks,
    required this.query,
  });

  int get total => leads.length + clients.length + tasks.length;
  bool get isEmpty => total == 0;
}

_SearchResults _search(
  String query,
  List<LeadModel> allLeads,
  List<ClientModel> allClients,
  List<TaskModel> allTasks,
) {
  final q = query.toLowerCase().trim();
  if (q.isEmpty) {
    return const _SearchResults(leads: [], clients: [], tasks: [], query: '');
  }

  final leads = allLeads.where((l) =>
    l.name.toLowerCase().contains(q) ||
    (l.companyName?.toLowerCase().contains(q) ?? false) ||
    (l.email?.toLowerCase().contains(q) ?? false) ||
    l.phone.contains(q) ||
    (l.service?.toLowerCase().contains(q) ?? false) ||
    l.stage.toLowerCase().contains(q),
  ).toList();

  final clients = allClients.where((c) =>
    c.name.toLowerCase().contains(q) ||
    (c.companyName?.toLowerCase().contains(q) ?? false) ||
    (c.email?.toLowerCase().contains(q) ?? false) ||
    c.phone.contains(q) ||
    (c.service?.toLowerCase().contains(q) ?? false),
  ).toList();

  final tasks = allTasks.where((t) =>
    t.title.toLowerCase().contains(q) ||
    (t.notes?.toLowerCase().contains(q) ?? false),
  ).toList();

  return _SearchResults(leads: leads, clients: clients, tasks: tasks, query: query);
}

// ── Page ──────────────────────────────────────────────────────────────────────
class GlobalSearchPage extends ConsumerStatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  ConsumerState<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends ConsumerState<GlobalSearchPage> {
  final _controller = TextEditingController();
  final _focusNode  = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync   = ref.watch(leadsProvider);
    final clientsAsync = ref.watch(clientsStreamProvider);
    final tasksAsync   = ref.watch(tasksStreamProvider);

    final allLeads   = leadsAsync.value   ?? [];
    final allClients = clientsAsync.value ?? [];
    final allTasks   = tasksAsync.value   ?? [];

    final isLoading = leadsAsync.isLoading || clientsAsync.isLoading || tasksAsync.isLoading;
    final results = _search(_query, allLeads, allClients, allTasks);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 12, offset: const Offset(0, 4)),
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 16),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text('Search', style: TextStyle(color: AppColors.textDark, fontSize: 24, fontWeight: FontWeight.w800)),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 5)),
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: AppColors.textDark, fontSize: 15),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Leads, clients, tasks…',
                        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppColors.textLight, size: 20),
                                onPressed: () => setState(() { _controller.clear(); _query = ''; }),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ───────────────────────────────────────────────────────
            Expanded(
              child: _buildBody(context, results, isLoading),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, _SearchResults results, bool isLoading) {
    // Empty query — show hint
    if (_query.isEmpty) {
      return _EmptyState(
        icon: Symbols.search,
        title: 'Search everything',
        subtitle: 'Find leads by name, company, phone\nClients by name or service\nTasks by title or notes',
      );
    }

    // Loading
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2));
    }

    // No results
    if (results.isEmpty) {
      return _EmptyState(
        icon: Symbols.search_off,
        title: 'No results for "${results.query}"',
        subtitle: 'Try a different name, phone number or keyword',
      );
    }

    // Results grouped by category
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      children: [
        if (results.leads.isNotEmpty) ...[
          _SectionHeader(
            icon: Symbols.leaderboard,
            label: 'Leads',
            count: results.leads.length,
            color: AppColors.primaryGlow,
          ),
          ...results.leads.map((l) => _LeadTile(lead: l, query: _query)),
          const SizedBox(height: 16),
        ],
        if (results.clients.isNotEmpty) ...[
          _SectionHeader(
            icon: Symbols.people,
            label: 'Clients',
            count: results.clients.length,
            color: AppColors.primary,
          ),
          ...results.clients.map((c) => _ClientTile(client: c, query: _query)),
          const SizedBox(height: 16),
        ],
        if (results.tasks.isNotEmpty) ...[
          _SectionHeader(
            icon: Symbols.task_alt,
            label: 'Tasks',
            count: results.tasks.length,
            color: AppColors.primaryMid,
          ),
          ...results.tasks.map((t) => _TaskTile(task: t, query: _query)),
        ],
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  const _SectionHeader({required this.icon, required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(children: [
        Container(width: 3, height: 18,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 15),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(20)),
          child: Text('$count', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

// ── Highlighted text helper ───────────────────────────────────────────────────
class _Highlighted extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle baseStyle;
  const _Highlighted({required this.text, required this.query, required this.baseStyle});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: baseStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
    final lower   = text.toLowerCase();
    final qLower  = query.toLowerCase();
    final idx     = lower.indexOf(qLower);
    if (idx == -1) return Text(text, style: baseStyle, maxLines: 1, overflow: TextOverflow.ellipsis);

    return Text.rich(
      TextSpan(children: [
        if (idx > 0) TextSpan(text: text.substring(0, idx), style: baseStyle),
        TextSpan(
          text: text.substring(idx, idx + query.length),
          style: baseStyle.copyWith(
            color: AppColors.primary,
            backgroundColor: AppColors.primaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (idx + query.length < text.length)
          TextSpan(text: text.substring(idx + query.length), style: baseStyle),
      ]),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ── Result tile base ──────────────────────────────────────────────────────────
class _ResultTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  const _ResultTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.07), blurRadius: 14, offset: const Offset(0, 4)),
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  if (subtitle != null) ...[const SizedBox(height: 3), subtitle!],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            const SizedBox(width: 6),
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Lead tile ─────────────────────────────────────────────────────────────────
class _LeadTile extends StatelessWidget {
  final LeadModel lead;
  final String query;
  const _LeadTile({required this.lead, required this.query});

  Color _stageColor() {
    switch (lead.stage) {
      case 'Won':         return AppColors.primary;
      case 'Lost':        return AppColors.danger;
      case 'Proposal':    return AppColors.primarySoft;
      case 'Negotiation': return AppColors.primary;
      default:            return AppColors.primaryGlow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = lead.name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join('').toUpperCase();
    final stageC   = _stageColor();

    return _ResultTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LeadDetailPage(lead: lead))),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primaryLight,
        child: Text(initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
      title: _Highlighted(
        text: lead.name,
        query: query,
        baseStyle: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: lead.companyName != null && lead.companyName!.isNotEmpty
          ? _Highlighted(
              text: lead.companyName!,
              query: query,
              baseStyle: const TextStyle(color: AppColors.textMid, fontSize: 12),
            )
          : Text(lead.phone, style: const TextStyle(color: AppColors.textMid, fontSize: 12)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: stageC.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(lead.stage, style: TextStyle(color: stageC, fontSize: 10, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ── Client tile ───────────────────────────────────────────────────────────────
class _ClientTile extends StatelessWidget {
  final ClientModel client;
  final String query;
  const _ClientTile({required this.client, required this.query});

  Color _statusColor() {
    switch (client.status) {
      case ClientStatus.vip:      return AppColors.primaryMid;
      case ClientStatus.active:   return AppColors.primary;
      case ClientStatus.inactive: return AppColors.textLight;
      default:                    return AppColors.primaryGlow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = client.name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join('').toUpperCase();
    final statusC  = _statusColor();

    return _ResultTile(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ClientDetailPage(client: client))),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: statusC.withOpacity(0.15),
        child: Text(initials, style: TextStyle(color: statusC, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
      title: _Highlighted(
        text: client.name,
        query: query,
        baseStyle: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: client.companyName != null && client.companyName!.isNotEmpty
          ? _Highlighted(
              text: client.companyName!,
              query: query,
              baseStyle: const TextStyle(color: AppColors.textMid, fontSize: 12),
            )
          : Text(client.phone, style: const TextStyle(color: AppColors.textMid, fontSize: 12)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: statusC.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(client.status, style: TextStyle(color: statusC, fontSize: 10, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ── Task tile ─────────────────────────────────────────────────────────────────
class _TaskTile extends StatelessWidget {
  final TaskModel task;
  final String query;
  const _TaskTile({required this.task, required this.query});

  Color _priorityColor() {
    switch (task.priority) {
      case 'High':   return AppColors.danger;
      case 'Low':    return AppColors.primary;
      default:       return AppColors.primarySoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priC      = _priorityColor();
    final dateLabel = DateFormat('d MMM, h:mm a').format(task.scheduledAt);
    final isOverdue = !task.isDone && task.scheduledAt.isBefore(DateTime.now());

    return _ResultTile(
      onTap: () {
        // Tasks don't have their own detail page — show a quick info bottom sheet
        _showTaskSheet(context, task);
      },
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: task.isDone ? AppColors.border : priC.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          task.isDone ? Icons.check_rounded : Symbols.task_alt,
          color: task.isDone ? AppColors.textLight : priC,
          size: 20,
        ),
      ),
      title: _Highlighted(
        text: task.title,
        query: query,
        baseStyle: TextStyle(
          color: task.isDone ? AppColors.textLight : AppColors.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          decoration: task.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(Symbols.schedule, size: 12, color: isOverdue ? AppColors.danger : AppColors.textLight),
          const SizedBox(width: 4),
          Text(
            dateLabel,
            style: TextStyle(color: isOverdue ? AppColors.danger : AppColors.textMid, fontSize: 12),
          ),
          if (task.isDone) ...[
            const SizedBox(width: 8),
            const Text('Done', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: priC.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
        child: Text(task.priority, style: TextStyle(color: priC, fontSize: 10, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

void _showTaskSheet(BuildContext context, TaskModel task) {
  final priC = task.priority == 'High'
      ? AppColors.danger
      : task.priority == 'Low'
          ? AppColors.primary
          : AppColors.primarySoft;
  final dateLabel = DateFormat('EEEE, d MMM yyyy • h:mm a').format(task.scheduledAt);

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: priC.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(Symbols.task_alt, color: priC, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: const TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(dateLabel, style: const TextStyle(color: AppColors.textMid, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          if (task.notes != null && task.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Text(task.notes!, style: const TextStyle(color: AppColors.textMid, fontSize: 13, height: 1.5)),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoChip(label: task.priority, color: priC),
              const SizedBox(width: 8),
              _InfoChip(
                label: task.isDone ? 'Completed' : 'Pending',
                color: task.isDone ? AppColors.primary : AppColors.textLight,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Empty / hint state ────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: AppColors.textLight, fontSize: 13, height: 1.5), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
