import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/providers.dart';

class ForecastScreen extends ConsumerStatefulWidget {
  const ForecastScreen({super.key});
  @override
  ConsumerState<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends ConsumerState<ForecastScreen> {
  double _revenueGrowth = 5;
  double _expenseGrowth = 3;
  double _hiringCost = 0;
  int _months = 12;

  @override
  void initState() {
    super.initState();
    ref.read(forecastProvider.notifier).load();
  }

  void _loadForecast() {
    ref.read(forecastProvider.notifier).load(months: _months, revenueGrowth: _revenueGrowth, expenseGrowth: _expenseGrowth, hiringCost: _hiringCost);
  }

  @override
  Widget build(BuildContext context) {
    final forecastState = ref.watch(forecastProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Cash Flow Forecasting')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputSection(),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _loadForecast, icon: const Icon(Icons.refresh), label: const Text('Generate Forecast'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B1F3A), foregroundColor: Colors.white)),
            const SizedBox(height: 24),
            forecastState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (result) {
                if (result == null) return const Center(child: Text('Tap Generate to view forecast'));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoCards(result.currentCash, result.currentBurnRate, result.currentRunway),
                    const SizedBox(height: 16),
                    const Text('Projection Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(height: 250, child: _forecastChart(result)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Forecast Parameters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Months: $_months'),
            Slider(value: _months.toDouble(), min: 3, max: 36, divisions: 11, onChanged: (v) => setState(() => _months = v.round())),
            Text('Revenue Growth: ${_revenueGrowth.toStringAsFixed(1)}%/mo'),
            Slider(value: _revenueGrowth, min: 0, max: 20, divisions: 40, onChanged: (v) => setState(() => _revenueGrowth = v)),
            Text('Expense Growth: ${_expenseGrowth.toStringAsFixed(1)}%/mo'),
            Slider(value: _expenseGrowth, min: 0, max: 20, divisions: 40, onChanged: (v) => setState(() => _expenseGrowth = v)),
            Text('Hiring Cost: \$${_hiringCost.toStringAsFixed(0)}'),
            Slider(value: _hiringCost, min: 0, max: 50000, divisions: 50, onChanged: (v) => setState(() => _hiringCost = v)),
          ],
        ),
      ),
    );
  }

  Widget _infoCards(double cash, int burn, int runway) {
    return Row(
      children: [
        _card('Cash', '\$${cash.toStringAsFixed(0)}', Colors.blue),
        _card('Burn Rate', '\$${burn.toStringAsFixed(0)}', Colors.red),
        _card('Runway', '$runway mo', runway < 6 ? Colors.red : Colors.green),
      ],
    );
  }

  Widget _card(String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ]),
        ),
      ),
    );
  }

  Widget _forecastChart(dynamic result) {
    final allData = [...result.historical, ...result.projections];
    if (allData.isEmpty) return const Center(child: Text('No data'));
    final spots = allData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.cashBalance)).toList();
    final dividerIndex = result.historical.length.toDouble();
    return LineChart(LineChartData(
      gridData: const FlGridData(show: true),
      extraLinesData: ExtraLinesData(horizontalLines: [HorizontalLine(y: 0, color: Colors.red, strokeWidth: 1)]),
      lineBarsData: [
        LineChartBarData(spots: spots, isCurved: true, color: Colors.blue, barWidth: 2, dotData: const FlDotData(show: false)),
      ],
    ));
  }
}