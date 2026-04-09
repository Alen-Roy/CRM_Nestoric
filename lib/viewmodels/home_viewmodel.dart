import 'package:crm/viewmodels/leads_viewmodel.dart';
import 'package:crm/viewmodels/task_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Home stats data class ─────────────────────────────────────────────────────
class HomeStats {
  final int totalLeads;
  final int dealsWon;
  final double totalRevenue;
  final int tasksToday;

  const HomeStats({
    this.totalLeads = 0,
    this.dealsWon = 0,
    this.totalRevenue = 0,
    this.tasksToday = 0,
  });
}

// ── Provider ──────────────────────────────────────────────────────────────────
// Combines leadsProvider + tasksStreamProvider to compute all dashboard stats.
// Rebuilds automatically whenever any lead or task changes in Firestore.
// Resilient: if tasks stream errors, still shows lead stats with tasksToday = 0.
final homeStatsProvider = Provider<AsyncValue<HomeStats>>((ref) {
  final leadsAsync = ref.watch(leadsProvider);
  final tasksAsync = ref.watch(tasksStreamProvider);

  // Leads are required — propagate loading/error states for leads.
  if (leadsAsync.isLoading) return const AsyncValue.loading();
  if (leadsAsync.hasError) {
    return AsyncValue.error(leadsAsync.error!, leadsAsync.stackTrace!);
  }

  final leads = leadsAsync.value ?? [];

  // Won leads
  final wonLeads = leads.where((l) => l.stage == 'Won').toList();

  // Sum revenue from Won leads (strip currency symbols before parsing)
  double revenue = 0;
  for (final lead in wonLeads) {
    if (lead.amount != null && lead.amount!.isNotEmpty) {
      final cleaned = lead.amount!.replaceAll(RegExp(r'[₹\$,\s]'), '').trim();
      revenue += double.tryParse(cleaned) ?? 0;
    }
  }

  // Count tasks scheduled for today (not done).
  // Gracefully degrades to 0 if tasks stream is still loading or errored.
  int todayTasks = 0;
  if (tasksAsync.hasValue) {
    final tasks = tasksAsync.value ?? [];
    final today = DateTime.now();
    todayTasks = tasks.where((t) {
      return !t.isDone &&
          t.scheduledAt.year == today.year &&
          t.scheduledAt.month == today.month &&
          t.scheduledAt.day == today.day;
    }).length;
  }

  return AsyncValue.data(
    HomeStats(
      totalLeads: leads.length,
      dealsWon: wonLeads.length,
      totalRevenue: revenue,
      tasksToday: todayTasks,
    ),
  );
});
