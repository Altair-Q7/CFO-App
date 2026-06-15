import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_constants.dart';
import '../../services/mock_data_service.dart';
import '../../providers/providers.dart';
import '../../widgets/madi_presence_indicator.dart';

class FounderDashboardScreen extends ConsumerStatefulWidget {
  const FounderDashboardScreen({super.key});

  @override
  ConsumerState<FounderDashboardScreen> createState() => _FounderDashboardScreenState();
}

class _FounderDashboardScreenState extends ConsumerState<FounderDashboardScreen> {
  final _mock = MockDataService();
  int? _selectedMonth;

  static const _revenueSpots = [
    FlSpot(0, 120000), FlSpot(1, 135000), FlSpot(2, 148000),
    FlSpot(3, 162000), FlSpot(4, 174000), FlSpot(5, 185000),
  ];

  static const _expenseSpots = [
    FlSpot(0, 85000), FlSpot(1, 92000), FlSpot(2, 98000),
    FlSpot(3, 105000), FlSpot(4, 118000), FlSpot(5, 125000),
  ];

  String _getMadiChartComment(int month) {
    const comments = [
      'January: Revenue at \u20B91.2L. Expenses at \u20B985K. Margin: 29%.',
      'February: Revenue grew 12.5%. Expense growth outpaced at 8%.',
      'March: First month expenses exceeded \u20B995K. Payroll expanded.',
      'April: Revenue gap widening. Margin improved to 35%.',
      'May: Burn rate acceleration. Payroll added 2 headcount.',
      'June: Revenue \u20B91.85L. Burn \u20B91.25L. Net: \u20B960K. Runway: 11 months.',
    ];
    return comments[month.clamp(0, 5)];
  }

  @override
  Widget build(BuildContext context) {
    final activity = _mock.getMockActivity();
    final transactions = activity['transactions'] as List;
    final recentTxns = transactions.sublist(
      transactions.length > 5 ? transactions.length - 5 : 0,
    );

    return Scaffold(
      backgroundColor: AppTheme.baseColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor(context),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TechFlow Inc.', style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary,
            )),
            Text('Founder \u00B7 Financial Operations', style: TextStyle(
              fontSize: 11, color: AppTheme.textSecondary,
            )),
          ],
        ),
        actions: [
          const MadiPresenceIndicator(),
          const SizedBox(width: 8),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.textOnDark
                        : AppTheme.textPrimary),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
              Positioned(
                right: 8, top: 8,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.coral,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded,
                color: AppTheme.onSurfaceTextSecondary(context), size: 20),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        color: AppTheme.navyDeep,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildMadiBriefing(),
            _buildRunwayHero(),
            _buildMetricsGrid(),
            _buildQuickActions(),
            _buildTrendChart(),
            _buildRecentTransactions(recentTxns),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMadiBriefing() {
    final data = _mock.getMadiBriefing();
    final sentences = data['sentences'] as List<String>;
    final status = data['healthStatus'] as String? ?? data['status'] as String;
    final actionText = data['recommendedAction'] as String?;
    final route = data['actionRoute'] as String?;

    final statusColor = switch (status) {
      'healthy' => AppTheme.emerald,
      'critical' => AppTheme.coral,
      _ => AppTheme.amber,
    };

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.madiBriefingGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyDeep.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text('M', style: TextStyle(
                    color: AppTheme.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ))),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MADI', style: TextStyle(
                      color: AppTheme.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    )),
                    Text('Financial Briefing', style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    )),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sentences.asMap().entries.map((entry) {
                final i = entry.key;
                final sentence = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 7),
                        width: 4, height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == 0
                              ? AppTheme.gold
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(sentence, style: TextStyle(
                          fontSize: 14,
                          fontWeight: i == 0 ? FontWeight.w600 : FontWeight.w400,
                          height: 1.6,
                          color: i == 0
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.75),
                        )),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          if (actionText != null && route != null)
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, route),
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_right_alt_rounded,
                        color: statusColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(actionText, style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      )),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: Colors.white.withValues(alpha: 0.4), size: 18),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRunwayHero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RUNWAY', style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppTheme.onSurfaceTextSecondary(context),
                )),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('11', style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2,
                      color: AppTheme.onSurfaceText(context),
                      height: 1.0,
                    )),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 6),
                      child: Text('months', style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurfaceTextSecondary(context),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 11 / 24,
                    backgroundColor: AppTheme.borderColor(context),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.amber,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Below 12-month benchmark',
                  style: TextStyle(fontSize: 12, color: AppTheme.amber)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _runwayStat('Burn Rate', '\u20B995K/mo', AppTheme.coral),
              const SizedBox(height: 12),
              _runwayStat('Cash', '\u20B912.4L', AppTheme.emerald),
              const SizedBox(height: 12),
              _runwayStat('Profit', '\u20B960K/mo', AppTheme.emerald),
            ],
          ),
        ],
      ),
    );
  }

  Widget _runwayStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(
          fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500,
        )),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: color,
        )),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = [
      {
        'label': 'REVENUE',
        'value': '\u20B91.85L',
        'change': '+12.5%',
        'positive': true,
        'icon': Icons.trending_up_rounded,
        'color': AppTheme.emerald,
      },
      {
        'label': 'EXPENSES',
        'value': '\u20B91.25L',
        'change': '+3.2%',
        'positive': false,
        'icon': Icons.trending_down_rounded,
        'color': AppTheme.coral,
      },
      {
        'label': 'NET PROFIT',
        'value': '\u20B960K',
        'change': '+8.1%',
        'positive': true,
        'icon': Icons.account_balance_outlined,
        'color': AppTheme.emerald,
      },
      {
        'label': 'EMPLOYEES',
        'value': '28',
        'change': '+2 this mo',
        'positive': true,
        'icon': Icons.people_outline_rounded,
        'color': const Color(0xFF6366F1),
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
        children: metrics.map((m) => _buildMetricCard(m)).toList(),
      ),
    );
  }

  Widget _buildMetricCard(Map<String, dynamic> m) {
    final color = m['color'] as Color;
    final positive = m['positive'] as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(m['label'] as String, style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: AppTheme.textMuted,
              )),
              Icon(m['icon'] as IconData, size: 16, color: color),
            ],
          ),
          Text(m['value'] as String, style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppTheme.onSurfaceText(context),
          )),
          Row(
            children: [
              Icon(
                positive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 11,
                color: color,
              ),
              const SizedBox(width: 3),
              Text(m['change'] as String, style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'label': 'Forecast', 'icon': Icons.trending_up_rounded, 'route': '/forecast'},
      {'label': 'Reports', 'icon': Icons.receipt_long_rounded, 'route': '/reports'},
      {'label': 'Advisors', 'icon': Icons.people_rounded, 'route': '/marketplace'},
      {'label': 'Fundraise', 'icon': Icons.rocket_launch_rounded, 'route': '/fundraising'},
    ];

    return Container(
      height: 80,
      margin: const EdgeInsets.fromLTRB(16, 0, 0, 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final a = actions[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, a['route'] as String),
            child: Container(
              width: 90,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderColor(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(a['icon'] as IconData,
                      size: 22,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.gold
                          : AppTheme.navyDeep),
                  const SizedBox(height: 6),
                  Text(a['label'] as String, style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.textOnDark
                        : AppTheme.textPrimary,
                  )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendChart() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TREND', style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppTheme.textSecondary,
              )),
              Row(children: [
                _legendDot(AppTheme.emerald, 'Revenue'),
                const SizedBox(width: 12),
                _legendDot(AppTheme.coral, 'Expenses'),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedMonth != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.navyDeep.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.gold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Text('M', style: TextStyle(
                    color: AppTheme.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  )),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getMadiChartComment(_selectedMonth!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50000,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.borderColor(context),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                        final i = value.toInt();
                        if (i < 0 || i >= months.length) return const SizedBox();
                        return Text(months[i], style: const TextStyle(
                          fontSize: 10, color: AppTheme.textMuted,
                        ));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchCallback: (event, response) {
                    if (event is FlTapUpEvent && response?.lineBarSpots != null) {
                      setState(() {
                        _selectedMonth = response!.lineBarSpots![0].x.toInt();
                      });
                    }
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
                      '\u20B9${(s.y / 1000).toStringAsFixed(0)}K',
                      TextStyle(
                        color: s.bar.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    )).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _revenueSpots,
                    isCurved: true,
                    color: AppTheme.emerald,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: AppTheme.emerald,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.emerald.withValues(alpha: 0.06),
                    ),
                  ),
                  LineChartBarData(
                    spots: _expenseSpots,
                    isCurved: true,
                    color: AppTheme.coral,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: AppTheme.coral,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.coral.withValues(alpha: 0.04),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(children: [
      Container(
        width: 8, height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(
        fontSize: 11, color: AppTheme.textSecondary,
      )),
    ]);
  }

  Widget _buildRecentTransactions(List transactions) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('RECENT TRANSACTIONS', style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppTheme.textSecondary,
            )),
          ),
          ...transactions.map((t) {
            final isIncome = t.type == 'income';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: (isIncome ? AppTheme.emerald : AppTheme.coral).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      color: isIncome ? AppTheme.emerald : AppTheme.coral,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.description, style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        )),
                        const SizedBox(height: 2),
                        Text('${t.date} \u00B7 ${t.category}', style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        )),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'}\$${_formatNumber(t.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isIncome ? AppTheme.emerald : AppTheme.coral,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
