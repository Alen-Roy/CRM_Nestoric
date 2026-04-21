import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/models/meeting_session_model.dart';
import 'package:crm/viewmodels/meeting_session_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crm/features/admin/viewmodels/admin_viewmodel.dart';
import 'package:crm/models/activity_model.dart';
import 'package:crm/models/lead_model.dart';
import 'package:crm/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class WorkerReportPage extends ConsumerStatefulWidget {
  final String userId;
  final String workerName;

  const WorkerReportPage({
    super.key,
    required this.userId,
    required this.workerName,
  });

  @override
  ConsumerState<WorkerReportPage> createState() => _WorkerReportPageState();
}

class _WorkerReportPageState extends ConsumerState<WorkerReportPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leadsAsync  = ref.watch(adminAllLeadsProvider);
    final tasksAsync  = ref.watch(adminAllTasksProvider);
    final activAsync  = ref.watch(adminAllActivitiesProvider);

    final leads      = leadsAsync.value?.where((l) => l.userId == widget.userId).toList() ?? [];
    final tasks      = tasksAsync.value?.where((t) => t.userId == widget.userId).toList() ?? [];
    final activities = activAsync.value?.where((a) => a.createdBy == widget.userId).toList() ?? [];

    final wonLeads    = leads.where((l) => l.stage == 'Won').toList();
    final revenue     = wonLeads.fold<double>(
        0, (s, l) => s + (double.tryParse(l.amount ?? '0') ?? 0));
    final winRate     = leads.isEmpty ? 0.0 : wonLeads.length / leads.length * 100;
    final tasksDone   = tasks.where((t) => t.isDone).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Hero header ─────────────────────────────────────────────────
          _WorkerHero(
            name:       widget.workerName,
            totalLeads: leads.length,
            wonLeads:   wonLeads.length,
            revenue:    revenue,
            winRate:    winRate,
            tasksDone:  tasksDone,
            totalTasks: tasks.length,
            activities: activities.length,
          ),

          // ── Tab bar ──────────────────────────────────────────────────────
          Container(
            color: AppColors.background,
            child: TabBar(
              controller: _tabs,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMid,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(text: 'Leads'),
                Tab(text: 'Tasks'),
                Tab(text: 'Activities'),
                Tab(text: 'Meetings'),
              ],
            ),
          ),

          // ── Tab content ──────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _WorkerLeadsTab(leads: leads),
                _WorkerTasksTab(tasks: tasks, ref: ref),
                _WorkerActivitiesTab(activities: activities),
                _WorkerMeetingsTab(userId: widget.userId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero
// ─────────────────────────────────────────────────────────────────────────────
class _WorkerHero extends StatelessWidget {
  final String name;
  final int totalLeads, wonLeads, tasksDone, totalTasks, activities;
  final double revenue, winRate;

  const _WorkerHero({
    required this.name,
    required this.totalLeads,
    required this.wonLeads,
    required this.revenue,
    required this.winRate,
    required this.tasksDone,
    required this.totalTasks,
    required this.activities,
  });

  String _fmt(double v) => v >= 1000
      ? '₹${(v / 1000).toStringAsFixed(1)}k'
      : '₹${v.toStringAsFixed(0)}';

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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Symbols.arrow_back,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                      Text('Worker Report',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // KPI grid 2x3
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 1.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _miniKpi('Total Leads', '$totalLeads'),
                  _miniKpi('Won Deals', '$wonLeads'),
                  _miniKpi('Revenue', _fmt(revenue)),
                  _miniKpi('Win Rate', '${winRate.toStringAsFixed(0)}%'),
                  _miniKpi('Tasks Done', '$tasksDone / $totalTasks'),
                  _miniKpi('Activities', '$activities'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniKpi(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 9,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Leads Tab
// ─────────────────────────────────────────────────────────────────────────────
class _WorkerLeadsTab extends ConsumerStatefulWidget {
  final List<LeadModel> leads;
  const _WorkerLeadsTab({required this.leads});
  @override
  ConsumerState<_WorkerLeadsTab> createState() => _WorkerLeadsTabState();
}

class _WorkerLeadsTabState extends ConsumerState<_WorkerLeadsTab> {
  String _filter = 'All';

  static const _stages = ['All', 'New', 'Proposal', 'Negotiation', 'Won', 'Lost'];
  static const _stageColors = {
    'New': AppColors.primaryGlow,
    'Proposal': AppColors.primaryMid,
    'Negotiation': AppColors.primary,
    'Won': AppColors.success,
    'Lost': AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All'
        ? widget.leads
        : widget.leads.where((l) => l.stage == _filter).toList();

    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _stages.map((s) {
                final sel = s == _filter;
                final col = _stageColors[s] ?? AppColors.primary;
                return GestureDetector(
                  onTap: () => setState(() => _filter = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? col : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: sel ? col : AppColors.border),
                    ),
                    child: Text(s,
                        style: TextStyle(
                            color: sel ? Colors.white : AppColors.textMid,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Text('${filtered.length} leads',
                  style: const TextStyle(
                      color: AppColors.textMid,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('No leads',
                      style: TextStyle(color: AppColors.textLight)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _WorkerLeadTile(
                      lead: filtered[i], ref: ref),
                ),
        ),
      ],
    );
  }
}

class _WorkerLeadTile extends StatelessWidget {
  final LeadModel lead;
  final WidgetRef ref;
  const _WorkerLeadTile({required this.lead, required this.ref});

  static const _stages = ['New', 'Proposal', 'Negotiation', 'Won', 'Lost'];
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
    final amount = lead.amount?.isNotEmpty == true ? '₹${lead.amount}' : '—';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: stageColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                    child: Text(
                  lead.name[0].toUpperCase(),
                  style: TextStyle(
                      color: stageColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800),
                )),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lead.name,
                        style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Text(lead.companyName ?? lead.phone,
                        style: const TextStyle(
                            color: AppColors.textLight, fontSize: 11)),
                  ],
                ),
              ),
              Text(amount,
                  style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              // Stage dropdown
              _StageDropdown(
                leadId:   lead.id!,
                current:  lead.stage,
                stages:   _stages,
                colors:   _stageColors,
                ref:      ref,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StageDropdown extends StatelessWidget {
  final String leadId;
  final String current;
  final List<String> stages;
  final Map<String, Color> colors;
  final WidgetRef ref;
  const _StageDropdown({
    required this.leadId,
    required this.current,
    required this.stages,
    required this.colors,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final col = colors[current] ?? AppColors.primaryMid;
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: col.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: col.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current,
                style: TextStyle(
                    color: col,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 3),
            Icon(Icons.arrow_drop_down, color: col, size: 14),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Text('Change Stage',
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            ...stages.map((s) {
              final col = colors[s] ?? AppColors.primaryMid;
              final isSelected = s == current;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(adminActionsProvider.notifier)
                      .changeLeadStage(leadId, s);
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? col.withValues(alpha: 0.12)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isSelected
                            ? col
                            : AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: col, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Text(s,
                          style: TextStyle(
                              color: col,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      const Spacer(),
                      if (isSelected)
                        Icon(Icons.check, color: col, size: 18),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tasks Tab
// ─────────────────────────────────────────────────────────────────────────────
class _WorkerTasksTab extends StatelessWidget {
  final List<TaskModel> tasks;
  final WidgetRef ref;
  const _WorkerTasksTab({required this.tasks, required this.ref});

  @override
  Widget build(BuildContext context) {
    final pending   = tasks.where((t) => !t.isDone).toList();
    final completed = tasks.where((t) => t.isDone).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        if (pending.isNotEmpty) ...[
          _sectionHeader('Pending (${pending.length})'),
          const SizedBox(height: 8),
          ...pending.map((t) => _TaskTile(task: t, ref: ref)),
          const SizedBox(height: 18),
        ],
        if (completed.isNotEmpty) ...[
          _sectionHeader('Completed (${completed.length})'),
          const SizedBox(height: 8),
          ...completed.map((t) => _TaskTile(task: t, ref: ref)),
        ],
        if (tasks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No tasks',
                  style: TextStyle(color: AppColors.textLight)),
            ),
          ),
      ],
    );
  }

  Widget _sectionHeader(String t) => Text(t,
      style: const TextStyle(
          color: AppColors.textMid,
          fontSize: 12,
          fontWeight: FontWeight.w700));
}

class _TaskTile extends StatelessWidget {
  final TaskModel task;
  final WidgetRef ref;
  const _TaskTile({required this.task, required this.ref});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM, h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: task.isDone
            ? AppColors.success.withValues(alpha: 0.04)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: task.isDone ? AppColors.success.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () => ref
                .read(adminActionsProvider.notifier)
                .toggleTask(task.id!, !task.isDone),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task.isDone ? AppColors.success : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                    color: task.isDone
                        ? AppColors.success
                        : AppColors.border,
                    width: 2),
              ),
              child: task.isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: TextStyle(
                        color: task.isDone
                            ? AppColors.textLight
                            : AppColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null)),
                Text(fmt.format(task.scheduledAt),
                    style: const TextStyle(
                        color: AppColors.textLight, fontSize: 11)),
              ],
            ),
          ),
          // Priority badge
          _PriorityBadge(priority: task.priority),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = priority == 'High'
        ? AppColors.danger
        : priority == 'Low'
            ? AppColors.primary
            : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(priority,
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Activities Tab
// ─────────────────────────────────────────────────────────────────────────────
class _WorkerActivitiesTab extends StatelessWidget {
  final List<ActivityModel> activities;
  const _WorkerActivitiesTab({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
          child: Text('No activities logged',
              style: TextStyle(color: AppColors.textLight)));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: activities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _ActivityTile(activity: activities[i]),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityModel activity;
  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final type  = activity.type;
    final color = _color(type);
    final diff  = DateTime.now().difference(activity.createdAt);
    final time  = diff.inDays > 0
        ? '${diff.inDays}d ago'
        : diff.inHours > 0
            ? '${diff.inHours}h ago'
            : '${diff.inMinutes}m ago';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(type.icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${type.label}${activity.outcome?.isNotEmpty == true ? ': ${activity.outcome}' : ' logged'}',
                  style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                if (activity.notes?.isNotEmpty == true)
                  Text(activity.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.textLight, fontSize: 11)),
              ],
            ),
          ),
          Text(time,
              style: const TextStyle(
                  color: AppColors.textLight, fontSize: 11)),
        ],
      ),
    );
  }

  Color _color(ActivityType t) {
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
// Meetings Tab  (full history with location, inside WorkerReportPage)
// ─────────────────────────────────────────────────────────────────────────────
class _WorkerMeetingsTab extends ConsumerWidget {
  final String userId;
  const _WorkerMeetingsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workerMeetingHistoryProvider(userId));

    return historyAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
            color: AppColors.primary, strokeWidth: 2),
      ),
      error: (e, _) => Center(
        child: Text('Error: $e',
            style: const TextStyle(color: AppColors.danger)),
      ),
      data: (sessions) {
        if (sessions.isEmpty) {
          return _MeetingsEmptyState();
        }

        // Stats summary bar
        final total = sessions.length;
        final ended = sessions.where((s) => !s.isActive).toList();
        final withLoc = sessions.where((s) => s.lat != null).length;
        final totalMins = ended.fold<int>(0, (acc, s) {
          if (s.endTime == null) return acc;
          return acc + s.endTime!.difference(s.startTime).inMinutes;
        });
        final avgMins = ended.isEmpty ? 0 : (totalMins / ended.length).round();

        return Column(
          children: [
            // ── Stats strip ──────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MeetingStat('$total', 'Total'),
                  _StatDivider(),
                  _MeetingStat('$withLoc', 'With GPS'),
                  _StatDivider(),
                  _MeetingStat('${avgMins}m', 'Avg Duration'),
                ],
              ),
            ),

            // ── List ─────────────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _MeetingHistoryCard(session: sessions[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MeetingStat extends StatelessWidget {
  final String value;
  final String label;
  const _MeetingStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75), fontSize: 11)),
    ]);
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 32, color: Colors.white.withValues(alpha: 0.3));
  }
}

class _MeetingsEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.handshake_rounded,
              color: AppColors.primaryGlow, size: 34),
        ),
        const SizedBox(height: 16),
        const Text('No Meetings Yet',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('No meeting check-ins recorded yet.',
            style: TextStyle(color: AppColors.textMid, fontSize: 13)),
      ]),
    );
  }
}

// ── Individual meeting card inside WorkerReportPage ───────────────────────────
class _MeetingHistoryCard extends StatelessWidget {
  final MeetingSessionModel session;
  const _MeetingHistoryCard({required this.session});

  static final _dateFmt = DateFormat('d MMM yyyy');
  static final _timeFmt = DateFormat('hh:mm a');

  Future<void> _openMap() async {
    if (session.lat == null || session.lng == null) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${session.lat},${session.lng}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLoc = session.lat != null && session.lng != null;
    final isLive = session.isActive;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Top row ──────────────────────────────────────────────────────
        Row(children: [
          // Live / ended dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isLive ? AppColors.success : AppColors.primaryMid,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(session.leadName,
                  style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Row(children: [
                // Source type chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: session.sourceType == 'client'
                        ? AppColors.primarySoft
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    session.sourceType == 'client' ? 'Client' : 'Lead',
                    style: TextStyle(
                      color: session.sourceType == 'client'
                          ? AppColors.primary
                          : AppColors.primaryGlow,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isLive) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('LIVE',
                        style: TextStyle(
                            color: AppColors.success,
                            fontSize: 9,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ]),
            ]),
          ),
          // Duration chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              session.durationLabel,
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ]),

        const SizedBox(height: 10),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 10),

        // ── Time row ─────────────────────────────────────────────────────
        Row(children: [
          const Icon(Icons.calendar_today_rounded,
              size: 12, color: AppColors.textLight),
          const SizedBox(width: 5),
          Text(_dateFmt.format(session.startTime),
              style: const TextStyle(
                  color: AppColors.textMid, fontSize: 11)),
          const SizedBox(width: 14),
          const Icon(Icons.access_time_rounded,
              size: 12, color: AppColors.textLight),
          const SizedBox(width: 5),
          Text(_timeFmt.format(session.startTime),
              style: const TextStyle(
                  color: AppColors.textMid, fontSize: 11)),
          if (!isLive && session.endTime != null) ...[
            const Text(' → ',
                style:
                    TextStyle(color: AppColors.textLight, fontSize: 11)),
            Text(_timeFmt.format(session.endTime!),
                style: const TextStyle(
                    color: AppColors.textMid, fontSize: 11)),
          ],
        ]),

        const SizedBox(height: 10),

        // ── Location row ─────────────────────────────────────────────────
        if (hasLoc)
          Row(children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.location_pin,
                      color: AppColors.primary, size: 13),
                  const SizedBox(width: 6),
                  Text(
                    '${session.lat!.toStringAsFixed(5)}, '
                    '${session.lng!.toStringAsFixed(5)}',
                    style: const TextStyle(
                        color: AppColors.textMid,
                        fontSize: 10,
                        fontFamily: 'monospace'),
                  ),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _openMap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(children: [
                  Icon(Icons.map_rounded, color: Colors.white, size: 13),
                  SizedBox(width: 5),
                  Text('Open Map',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ])
        else
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(children: [
              Icon(Icons.location_off_rounded,
                  color: AppColors.danger, size: 13),
              SizedBox(width: 6),
              Text('No GPS location recorded',
                  style: TextStyle(
                      color: AppColors.danger, fontSize: 11)),
            ]),
          ),
      ]),
    );
  }
}
