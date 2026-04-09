import 'package:crm/core/constants/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  static const _months  = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  static const _revenue = [18.0, 25.0, 20.0, 32.0, 28.0, 38.0];

  static const _leadValues = [40.0, 20.0, 25.0, 15.0];
  static const _leadLabels = ['Won', 'Lost', 'Progress', 'New'];
  static const _leadColors = [
    AppColors.success,
    AppColors.danger,
    AppColors.warning,
    AppColors.secondary,
  ];

  static const _leaderboard = [
    {'name': 'Sarah Johnson', 'deals': 24, 'revenue': '\$48k'},
    {'name': 'Mark Williams', 'deals': 19, 'revenue': '\$36k'},
    {'name': 'Emily Davis',   'deals': 16, 'revenue': '\$30k'},
    {'name': 'James Brown',   'deals': 12, 'revenue': '\$24k'},
    {'name': 'Anna Smith',    'deals': 9,  'revenue': '\$18k'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            const Text('Reports', style: TextStyle(color: AppColors.textDark, fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),

            // ── Revenue bar chart ──────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardTitle('Monthly Revenue', Icons.bar_chart_rounded),
                  const SizedBox(height: 4),
                  const Text('Last 6 months (in \$k)', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                  const SizedBox(height: 20),
                  SizedBox(height: 180, child: _buildBarChart()),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Donut / lead conversion ────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardTitle('Lead Conversion', Icons.donut_large_rounded),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(width: 150, height: 150, child: _buildDonutChart()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildLegend()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Leaderboard ────────────────────────────────────────────────
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardTitle('Leaderboard', Icons.emoji_events_rounded),
                  const SizedBox(height: 12),
                  ..._leaderboard.asMap().entries.map((e) => _leaderboardTile(e.key, e.value)),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ── Bar chart ──────────────────────────────────────────────────────────────
  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        maxY: 45,
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
              reservedSize: 36,
              getTitlesWidget: (value, _) => Text('\$${value.toInt()}k', style: const TextStyle(color: AppColors.textLight, fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= _months.length) return const SizedBox();
                return Text(_months[idx], style: const TextStyle(color: AppColors.textMid, fontSize: 11));
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: _revenue.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                width: 18,
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryGlow],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Donut chart ────────────────────────────────────────────────────────────
  Widget _buildDonutChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 42,
        sections: List.generate(_leadValues.length, (i) {
          return PieChartSectionData(
            value: _leadValues[i],
            color: _leadColors[i],
            radius: 32,
            showTitle: false,
          );
        }),
      ),
    );
  }

  Widget _buildLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_leadLabels.length, (i) {
        final total = _leadValues.fold(0.0, (a, b) => a + b);
        final pct = (_leadValues[i] / total * 100).toStringAsFixed(0);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: _leadColors[i], borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 8),
              Expanded(child: Text(_leadLabels[i], style: const TextStyle(color: AppColors.textMid, fontSize: 13))),
              Text('$pct%', style: TextStyle(color: _leadColors[i], fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        );
      }),
    );
  }

  // ── Leaderboard tile ───────────────────────────────────────────────────────
  Widget _leaderboardTile(int rank, Map<String, dynamic> member) {
    const medalColors = [Color(0xFFFFD700), Color(0xFFB0B0B0), Color(0xFFCD7F32)];
    final isTop3 = rank < 3;
    final rankColor = isTop3 ? medalColors[rank] : AppColors.textLight;
    final initials = member['name'].toString().split(' ').map((w) => w[0]).take(2).join('');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('#${rank + 1}', style: TextStyle(color: rankColor, fontWeight: FontWeight.w700, fontSize: 14)),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Text(initials, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(member['name'], style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w500))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(member['revenue'], style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 13)),
              Text('${member['deals']} deals', style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
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

  Widget _card({required Widget child}) {
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
