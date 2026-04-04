import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  static const _revenue = [18.0, 25.0, 20.0, 32.0, 28.0, 38.0];

  static const _leadValues = [40.0, 20.0, 25.0, 15.0];
  static const _leadLabels = ['Won', 'Lost', 'Progress', 'New'];
  static const _leadColors = [
    Color(0xFF4ADE80),
    Color(0xFFF87171),
    Color(0xFFFBBF24),
    Color(0xFF60A5FA),
  ];

  static const _leaderboard = [
    {'name': 'Sarah Johnson', 'deals': 24, 'revenue': '\$48k'},
    {'name': 'Mark Williams', 'deals': 19, 'revenue': '\$36k'},
    {'name': 'Emily Davis', 'deals': 16, 'revenue': '\$30k'},
    {'name': 'James Brown', 'deals': 12, 'revenue': '\$24k'},
    {'name': 'Anna Smith', 'deals': 9, 'revenue': '\$18k'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Reports'),
            const SizedBox(height: 20),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardTitle('Monthly Revenue', Icons.bar_chart_rounded),
                  const SizedBox(height: 4),
                  const Text(
                    'Last 6 months (in \$k)',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(height: 180, child: _buildBarChart()),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardTitle('Lead Conversion', Icons.donut_large_rounded),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: _buildDonutChart(),
                      ),
                      const SizedBox(width: 24),
                      Expanded(child: _buildLegend()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cardTitle('Leaderboard', Icons.emoji_events_rounded),
                  const SizedBox(height: 12),
                  ..._leaderboard.asMap().entries.map(
                    (e) => _leaderboardTile(e.key, e.value),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        maxY: 45,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: Colors.white10, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, _) => Text(
                '\$${value.toInt()}k',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx < 0 || idx >= _months.length) return const SizedBox();
                return Text(
                  _months[idx],
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: _revenue.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                width: 18,
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
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

  Widget _buildDonutChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: List.generate(_leadValues.length, (i) {
          return PieChartSectionData(
            value: _leadValues[i],
            color: _leadColors[i],
            radius: 30,
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
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _leadColors[i],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _leadLabels[i],
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  color: _leadColors[i],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _leaderboardTile(int rank, Map<String, dynamic> member) {
    const medalColors = [
      Color(0xFFFFD700),
      Color(0xFFB0B0B0),
      Color(0xFFCD7F32), // bronze
    ];

    final isTop3 = rank < 3;
    final rankColor = isTop3 ? medalColors[rank] : Colors.white38;
    final initials = member['name']
        .toString()
        .split(' ')
        .map((w) => w[0])
        .take(2)
        .join('');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#${rank + 1}',
              style: TextStyle(
                color: rankColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color.fromRGBO(99, 102, 241, 0.25),
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member['name'],
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                member['revenue'],
                style: const TextStyle(
                  color: Color(0xFF4ADE80),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                '${member['deals']} deals',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _cardTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}
