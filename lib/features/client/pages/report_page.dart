import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crm/core/constants/app_colors.dart';
import 'package:crm/models/lead_model.dart';
import 'package:crm/viewmodels/leads_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── All activities for the current user (no orderBy → no composite index) ─────
final _allActivitiesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('activities')
      .where('createdBy', isEqualTo: user.uid)
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.data()).toList());
});

// ── Computed report data ───────────────────────────────────────────────────────
class _ReportData {
  // KPIs
  final int totalLeads;
  final int wonLeads;
  final int lostLeads;
  final double totalRevenue;
  final double avgDealSize;

  // Bar chart — revenue per month (last 6 months)
  final List<String> monthLabels;
  final List<double> monthRevenue;
  final double maxRevenue;

  // Donut — pipeline breakdown
  final Map<String, int> stageCounts;

  // Activity breakdown
  final Map<String, int> activityCounts;

  const _ReportData({
    required this.totalLeads,
    required this.wonLeads,
    required this.lostLeads,
    required this.totalRevenue,
    required this.avgDealSize,
    required this.monthLabels,
    required this.monthRevenue,
    required this.maxRevenue,
    required this.stageCounts,
    required this.activityCounts,
  });

  double get winRate => totalLeads == 0 ? 0 : wonLeads / totalLeads * 100;
}

_ReportData _compute(List<LeadModel> leads, List<Map<String, dynamic>> activities) {
  // ── Stage counts ──────────────────────────────────────────────────────────
  final stageCounts = <String, int>{'Won': 0, 'Lost': 0, 'In Progress': 0, 'New': 0};
  for (final l in leads) {
    final s = l.stage;
    if (s == 'Won' || s == 'Lost' || s == 'In Progress' || s == 'New') {
      stageCounts[s] = (stageCounts[s] ?? 0) + 1;
    } else {
      stageCounts['In Progress'] = (stageCounts['In Progress'] ?? 0) + 1;
    }
  }

  // ── Won leads ─────────────────────────────────────────────────────────────
  final wonList = leads.where((l) => l.stage == 'Won').toList();
  double totalRevenue = 0;
  for (final l in wonList) {
    if (l.amount != null && l.amount!.isNotEmpty) {
      final cleaned = l.amount!.replaceAll(RegExp(r'[₹\$,\s]'), '').trim();
      totalRevenue += double.tryParse(cleaned) ?? 0;
    }
  }
  final avgDeal = wonList.isEmpty ? 0.0 : totalRevenue / wonList.length;

  // ── Monthly revenue — last 6 calendar months ──────────────────────────────
  final now = DateTime.now();
  final months = List.generate(6, (i) {
    final d = DateTime(now.year, now.month - 5 + i, 1);
    return d;
  });
  final monthLabels = months.map((d) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[d.month - 1];
  }).toList();

  final monthRevenue = List<double>.filled(6, 0);
  for (final l in wonList) {
    final date = l.createdAt;
    if (date == null) continue;
    for (int i = 0; i < 6; i++) {
      if (date.year == months[i].year && date.month == months[i].month) {
        if (l.amount != null && l.amount!.isNotEmpty) {
          final cleaned = l.amount!.replaceAll(RegExp(r'[₹\$,\s]'), '').trim();
          monthRevenue[i] += double.tryParse(cleaned) ?? 0;
        }
        break;
      }
    }
  }

  final maxRevenue = monthRevenue.isEmpty ? 10.0
      : (monthRevenue.reduce((a, b) => a > b ? a : b) * 1.25).clamp(10.0, double.infinity);

  // ── Activity counts ───────────────────────────────────────────────────────
  final activityCounts = <String, int>{
    'call': 0, 'meeting': 0, 'email': 0, 'proposal': 0, 'note': 0,
  };
  for (final a in activities) {
    final type = a['type'] as String? ?? 'note';
    activityCounts[type] = (activityCounts[type] ?? 0) + 1;
  }

  return _ReportData(
    totalLeads: leads.length,
    wonLeads: wonList.length,
    lostLeads: stageCounts['Lost'] ?? 0,
    totalRevenue: totalRevenue,
    avgDealSize: avgDeal,
    monthLabels: monthLabels,
    monthRevenue: monthRevenue,
    maxRevenue: maxRevenue,
    stageCounts: stageCounts,
    activityCounts: activityCounts,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
class ReportPage extends ConsumerWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(leadsProvider);
    final activitiesAsync = ref.watch(_allActivitiesProvider);

    final isLoading = leadsAsync.isLoading || activitiesAsync.isLoading;
    final hasError  = leadsAsync.hasError;

    if (hasError) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Failed to load report data.', style: TextStyle(color: AppColors.textMid))),
      );
    }

    final leads     = leadsAsync.value ?? [];
    final activities = activitiesAsync.value ?? [];
    final data      = isLoading ? null : _compute(leads, activities);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            // ── Header ─────────────────────────────────────────────────────
            const Text('Reports',
                style: TextStyle(color: AppColors.textDark, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              isLoading ? 'Loading your data…' : '${leads.length} leads · ${activities.length} activities',
              style: const TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // ── KPI row ────────────────────────────────────────────────────
            _KpiRow(data: data),
            const SizedBox(height: 16),

            // ── Revenue bar chart ──────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardTitle('Monthly Revenue', Icons.bar_chart_rounded),
                  const SizedBox(height: 4),
                  const Text('Won deals by month (₹)',
                      style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 180,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                        : _RevenueBarChart(data: data!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Pipeline donut ─────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardTitle('Lead Pipeline', Icons.donut_large_rounded),
                  const SizedBox(height: 16),
                  isLoading
                      ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)))
                      : _PipelineDonut(data: data!),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Activity breakdown ─────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardTitle('Activity Breakdown', Icons.timeline_rounded),
                  const SizedBox(height: 14),
                  isLoading
                      ? const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)))
                      : _ActivityBreakdown(data: data!),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _cardTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 16)),
      ],
    );
  }

  static Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 5))],
      ),
      child: child,
    );
  }
}

// ── KPI Row ───────────────────────────────────────────────────────────────────
class _KpiRow extends StatelessWidget {
  final _ReportData? data;
  const _KpiRow({required this.data});

  @override
  Widget build(BuildContext context) {
    String fmtMoney(double v) {
      if (v >= 100000) return '₹${(v / 100000).toStringAsFixed(1)}L';
      if (v >= 1000)   return '₹${(v / 1000).toStringAsFixed(1)}k';
      return '₹${v.toStringAsFixed(0)}';
    }

    final kpis = [
      _KpiData('Win Rate',   data == null ? '—' : '${data!.winRate.toStringAsFixed(0)}%', AppColors.success),
      _KpiData('Revenue',    data == null ? '—' : fmtMoney(data!.totalRevenue),           AppColors.primary),
      _KpiData('Avg Deal',   data == null ? '—' : fmtMoney(data!.avgDealSize),            AppColors.accent3),
    ];

    return Row(
      children: kpis.map((k) => Expanded(
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(k.value,
                  style: TextStyle(color: k.color, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(k.label,
                  style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
            ],
          ),
        ),
      )).toList()
        ..last,
    );
  }
}

class _KpiData {
  final String label;
  final String value;
  final Color color;
  const _KpiData(this.label, this.value, this.color);
}

// ── Revenue Bar Chart ─────────────────────────────────────────────────────────
class _RevenueBarChart extends StatelessWidget {
  final _ReportData data;
  const _RevenueBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final allZero = data.monthRevenue.every((v) => v == 0);

    return BarChart(
      BarChartData(
        maxY: data.maxRevenue,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, _) {
                if (value == 0) return const SizedBox();
                String label;
                if (value >= 100000) label = '₹${(value / 100000).toStringAsFixed(0)}L';
                else if (value >= 1000) label = '₹${(value / 1000).toStringAsFixed(0)}k';
                else label = '₹${value.toInt()}';
                return Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 9));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.monthLabels.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(data.monthLabels[idx],
                      style: const TextStyle(color: AppColors.textMid, fontSize: 11)),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: data.monthRevenue.asMap().entries.map((e) {
          final isEmpty = e.value == 0;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: isEmpty && allZero ? 0 : e.value,
                width: 18,
                borderRadius: BorderRadius.circular(8),
                gradient: isEmpty
                    ? const LinearGradient(colors: [AppColors.border, AppColors.border])
                    : const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryGlow],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
              ),
            ],
          );
        }).toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, _, rod, __) {
              final v = rod.toY;
              if (v == 0) return null;
              String label;
              if (v >= 100000) label = '₹${(v / 100000).toStringAsFixed(1)}L';
              else if (v >= 1000) label = '₹${(v / 1000).toStringAsFixed(1)}k';
              else label = '₹${v.toStringAsFixed(0)}';
              return BarTooltipItem(label,
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12));
            },
          ),
        ),
      ),
    );
  }
}

// ── Pipeline Donut ────────────────────────────────────────────────────────────
class _PipelineDonut extends StatelessWidget {
  final _ReportData data;
  const _PipelineDonut({required this.data});

  static const _colors = {
    'Won':         AppColors.success,
    'In Progress': AppColors.warning,
    'New':         AppColors.secondary,
    'Lost':        AppColors.danger,
  };

  @override
  Widget build(BuildContext context) {
    final total = data.stageCounts.values.fold(0, (a, b) => a + b);
    final hasData = total > 0;

    final sections = data.stageCounts.entries
        .where((e) => e.value > 0)
        .map((e) => PieChartSectionData(
              value: e.value.toDouble(),
              color: _colors[e.key] ?? AppColors.border,
              radius: 34,
              showTitle: false,
            ))
        .toList();

    if (!hasData) {
      sections.add(PieChartSectionData(
        value: 1, color: AppColors.border, radius: 34, showTitle: false,
      ));
    }

    return Row(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: PieChart(PieChartData(
            sectionsSpace: hasData ? 3 : 0,
            centerSpaceRadius: 44,
            sections: sections,
          )),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: data.stageCounts.entries.map((e) {
              final pct = total == 0 ? 0.0 : e.value / total * 100;
              final color = _colors[e.key] ?? AppColors.border;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.key,
                        style: const TextStyle(color: AppColors.textMid, fontSize: 13))),
                    Text('${e.value}',
                        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(width: 4),
                    Text('(${pct.toStringAsFixed(0)}%)',
                        style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Activity Breakdown ────────────────────────────────────────────────────────
class _ActivityBreakdown extends StatelessWidget {
  final _ReportData data;
  const _ActivityBreakdown({required this.data});

  @override
  Widget build(BuildContext context) {
    const meta = {
      'call':     ('📞', 'Calls',     AppColors.secondary),
      'meeting':  ('🤝', 'Meetings',  AppColors.primary),
      'email':    ('📧', 'Emails',    AppColors.accent3),
      'proposal': ('📄', 'Proposals', AppColors.accent2),
      'note':     ('📝', 'Notes',     AppColors.textMid),
    };

    final total = data.activityCounts.values.fold(0, (a, b) => a + b);

    if (total == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text('No activities logged yet.',
              style: TextStyle(color: AppColors.textLight, fontSize: 13)),
        ),
      );
    }

    return Column(
      children: meta.entries.map((entry) {
        final key   = entry.key;
        final emoji = entry.value.$1;
        final label = entry.value.$2;
        final color = entry.value.$3;
        final count = data.activityCounts[key] ?? 0;
        final frac  = total == 0 ? 0.0 : count / total;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(width: 28, child: Text(emoji, style: const TextStyle(fontSize: 16))),
              const SizedBox(width: 6),
              SizedBox(
                width: 72,
                child: Text(label,
                    style: const TextStyle(color: AppColors.textMid, fontSize: 13)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: frac,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 24,
                child: Text('$count',
                    style: TextStyle(
                        color: count > 0 ? color : AppColors.textLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
