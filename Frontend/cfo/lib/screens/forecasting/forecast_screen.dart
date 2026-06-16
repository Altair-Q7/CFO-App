import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_constants.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/madi_logo.dart';
import '../../widgets/madi_presence_indicator.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final _mock = MockDataService();
  double _revenueGrowth = 5;
  double _expenseGrowth = 3;
  double _hiringCost = 0;
  int _months = 12;
  bool _loading = false;
  String _selectedScenario = 'moderate';

  static const _scenarios = {
    'conservative': {'label': 'Conservative', 'revenue': 2.0, 'expense': 5.0},
    'moderate': {'label': 'Moderate', 'revenue': 5.0, 'expense': 3.0},
    'aggressive': {'label': 'Aggressive', 'revenue': 10.0, 'expense': 1.0},
  };

  void _loadForecast() {
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.baseColor(context),
      appBar: AppBar(
        backgroundColor:
            isDark ? AppTheme.navyDeep : AppTheme.surfaceColor(context),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('Cash Flow Forecasting',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppTheme.textOnDark
                  : AppTheme.onSurfaceText(context),
            )),
        actions: [
          const MadiPresenceIndicator(),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMadiBriefing(),
            const SizedBox(height: 16),
            _buildParameterCard(isDark),
            const SizedBox(height: 16),
            _buildScenarioComparison(isDark),
            const SizedBox(height: 16),
            _buildGenerateButton(isDark),
            const SizedBox(height: 24),
            _buildScenarioSelector(isDark),
            const SizedBox(height: 16),
            _buildImpactMetrics(isDark),
            const SizedBox(height: 24),
            _buildChartSection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.gold.withValues(alpha: 0.15)
                      : AppTheme.navyDeep.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: isDark ? AppTheme.gold : AppTheme.navyDeep,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Forecast Parameters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.textOnDark
                      : AppTheme.onSurfaceText(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSlider('Months', _months.toDouble(), 3, 36,
              (v) => setState(() => _months = v.round()), ' months'),
          _buildSlider('Revenue Growth', _revenueGrowth, 0, 20,
              (v) => setState(() => _revenueGrowth = v), '%/mo'),
          _buildSlider('Expense Growth', _expenseGrowth, 0, 20,
              (v) => setState(() => _expenseGrowth = v), '%/mo'),
          _buildSlider('Monthly Hiring', _hiringCost, 0, 50000,
              (v) => setState(() => _hiringCost = v), r'$/mo',
              step: 1000),
        ],
      ),
    );
  }

  Widget _buildMadiBriefing() {
    final data = _mock.getMadiBriefing();
    final sentences = data['sentences'] as List<String>;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.navyGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyDeep.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const MadiLogo(size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('MADI',
                          style: TextStyle(
                            color: AppTheme.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          )),
                      const SizedBox(width: 8),
                      Text('Forecast Intelligence',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 11,
                          )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sentences.isNotEmpty
                        ? sentences.first
                        : 'Adjust parameters and generate to see projections.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      Function(double) onChanged, String suffix,
      {double step = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppTheme.gold : AppTheme.navyDeep;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.textOnDarkMuted
                        : AppTheme.onSurfaceTextSecondary(context))),
            Text(
              '${suffix == r'$/mo' ? '\$${value.toStringAsFixed(0)}' : value.toStringAsFixed(1)}$suffix',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.gold : AppTheme.navyDeep),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: accent,
            inactiveTrackColor: accent.withValues(alpha: 0.1),
            thumbColor: accent,
            overlayColor: accent.withValues(alpha: 0.1),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / step).round(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// Scenario comparison — shows what-if analysis across 3 scenarios
  Widget _buildScenarioComparison(bool isDark) {
    final result = _mock.getMockForecast(
      months: _months,
      revenueGrowth: _revenueGrowth,
      expenseGrowth: _expenseGrowth,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DECISION IMPACT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppTheme.onSurfaceTextSecondary(context),
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              _impactTile('Runway',
                  '${result.currentRunway} mo', AppTheme.amber, Icons.timer_outlined),
              const SizedBox(width: 8),
              _impactTile('End Cash',
                  '\$${_formatNumber(result.currentCash * 0.6.toDouble())}',
                  _months > 18 ? AppTheme.emerald : AppTheme.coral,
                  Icons.account_balance_outlined),
              const SizedBox(width: 8),
              _impactTile('Burn at Exit',
                  '\$${_formatNumber(result.currentBurnRate * _months.toDouble() / 12)}',
                  AppTheme.onSurfaceTextMuted(context),
                  Icons.local_fire_department_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactTile(
      String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.onSurfaceTextSecondary(context),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _loadForecast,
        icon: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.refresh_rounded),
        label: Text(_loading ? 'Generating...' : 'Generate Forecast'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppTheme.navyMid : AppTheme.navyDeep,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildScenarioSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SCENARIO COMPARISON',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppTheme.onSurfaceTextSecondary(context),
            )),
        const SizedBox(height: 12),
        Row(
          children: _scenarios.entries.map((entry) {
            final key = entry.key;
            final scenario = entry.value;
            final selected = _selectedScenario == key;
            final accent = isDark ? AppTheme.gold : AppTheme.navyDeep;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedScenario = key),
                child: Container(
                  margin: EdgeInsets.only(
                      right: key == 'aggressive' ? 0 : 8),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 4),
                  decoration: BoxDecoration(
                    color: selected
                        ? accent.withValues(alpha: 0.1)
                        : AppTheme.surfaceColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? accent : AppTheme.borderColor(context),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(scenario['label'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? accent
                                : AppTheme
                                    .onSurfaceTextSecondary(context),
                          )),
                      const SizedBox(height: 2),
                      Text(
                          '+${scenario['revenue']}% / ${scenario['expense']}%',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppTheme.onSurfaceTextMuted(context),
                          )),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImpactMetrics(bool isDark) {
    final result = _mock.getMockForecast(
      months: _months,
      revenueGrowth: _revenueGrowth,
      expenseGrowth: _expenseGrowth,
    );

    final selectedScenario = _scenarios[_selectedScenario]!;
    final scenarioResult = _mock.getMockForecast(
      months: _months,
      revenueGrowth: selectedScenario['revenue'] as double,
      expenseGrowth: selectedScenario['expense'] as double,
    );

    final currentRunway = result.currentRunway;
    final scenarioRunway = scenarioResult.currentRunway;
    final runwayDiff = scenarioRunway - currentRunway;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                  selectedScenario['label'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textOnDark
                        : AppTheme.onSurfaceText(context),
                  )),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (runwayDiff >= 0
                          ? AppTheme.emerald
                          : AppTheme.coral)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${runwayDiff >= 0 ? '+' : ''}${runwayDiff}mo vs base',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: runwayDiff >= 0
                        ? AppTheme.emerald
                        : AppTheme.coral,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoCard(
                  'Cash',
                  '\$${_formatNumber(scenarioResult.currentCash.toDouble())}',
                  AppTheme.emerald),
              _infoCard(
                  'Burn Rate',
                  '\$${_formatNumber(scenarioResult.currentBurnRate.toDouble())}',
                  AppTheme.amber),
              _infoCard(
                  'Runway',
                  '${scenarioResult.currentRunway} mo',
                  scenarioResult.currentRunway < 6
                      ? AppTheme.coral
                      : AppTheme.emerald),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.onSurfaceTextSecondary(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cash Balance Projection',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppTheme.textOnDark
                : AppTheme.onSurfaceText(context),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: _buildMultiScenarioChart(isDark),
        ),
      ],
    );
  }

  Widget _buildMultiScenarioChart(bool isDark) {
    final baseResult = _mock.getMockForecast(
      months: _months,
      revenueGrowth: _revenueGrowth,
      expenseGrowth: _expenseGrowth,
    );

    final baseSpots = _buildSpots(baseResult);

    // Build scenario lines
    final scenarioLines = <LineChartBarData>[];
    final scenarioColors = <Color>[
      AppTheme.emerald,
      AppTheme.amber,
      AppTheme.coral,
    ];

    _scenarios.entries.toList().asMap().forEach((i, entry) {
      final scenario = entry.value;
      final result = _mock.getMockForecast(
        months: _months,
        revenueGrowth: scenario['revenue'] as double,
        expenseGrowth: scenario['expense'] as double,
      );
      final spots = _buildSpots(result);
      scenarioLines.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: scenarioColors[i % scenarioColors.length],
          barWidth: 1.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      );
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppTheme.borderColor(context).withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) {
                return Text(
                  _formatNumber(value),
                  style: TextStyle(
                    fontSize: 9,
                    color: AppTheme.onSurfaceTextMuted(context),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final labels = ['Now', '+3mo', '+6mo', '+9mo', '+12mo'];
                final i = value.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(labels[i],
                      style: TextStyle(
                        fontSize: 9,
                        color: AppTheme.onSurfaceTextMuted(context),
                      )),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 0,
              color: AppTheme.coral,
              strokeWidth: 1.5,
              dashArray: [5, 5],
            ),
          ],
        ),
        lineBarsData: [
          // Base scenario (thick, highlighted)
          LineChartBarData(
            spots: baseSpots,
            isCurved: true,
            color: AppTheme.gold,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.gold.withValues(alpha: 0.1),
            ),
          ),
          ...scenarioLines,
        ],
      ),
    );
  }

  List<FlSpot> _buildSpots(dynamic result) {
    final allData = [...result.historical, ...result.projections];
    if (allData.isEmpty) return [];
    return allData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.cashBalance))
        .toList();
  }

  String _formatNumber(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}
