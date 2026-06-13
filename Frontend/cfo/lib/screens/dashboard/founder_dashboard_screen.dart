import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/providers.dart';

class FounderDashboardScreen extends ConsumerWidget {
  const FounderDashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);
    final trendsAsync = ref.watch(dashboardTrendsProvider);
    final activityAsync = ref.watch(dashboardActivityProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardMetricsProvider);
          ref.invalidate(dashboardTrendsProvider);
          ref.invalidate(dashboardActivityProvider);
        },
        child: metricsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (metrics) {
            if (metrics == null) return const Center(child: Text('No data. Complete onboarding first.'));
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Financial Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _metricsGrid(metrics),
                  const SizedBox(height: 24),
                  const Text('Revenue & Expenses Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  trendsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                    data: (trends) => SizedBox(height: 200, child: _trendChart(trends)),
                  ),
                  const SizedBox(height: 24),
                  const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  activityAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e'),
                    data: (activity) {
                      final transactions = activity['transactions'] as List;
                      final notifications = activity['notifications'] as List;
                      return Column(
                        children: [
                          ...notifications.map((n) => Card(
                            child: ListTile(
                              leading: Icon(Icons.notifications, color: n.read ? Colors.grey : Colors.orange),
                              title: Text(n.title),
                              subtitle: Text(n.message),
                              trailing: n.read ? null : const CircleAvatar(radius: 8, backgroundColor: Colors.red),
                            ),
                          )),
                          ...transactions.map((t) => Card(
                            child: ListTile(
                              leading: Icon(t.type == 'income' ? Icons.arrow_upward : Icons.arrow_downward, color: t.type == 'income' ? Colors.green : Colors.red),
                              title: Text(t.description),
                              subtitle: Text('${t.date} • ${t.category}'),
                              trailing: Text('\$${t.amount.toStringAsFixed(0)}', style: TextStyle(color: t.type == 'income' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          )),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _metricsGrid(dynamic m) {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _metricCard('Cash Balance', '\$${m.cashBalance.toStringAsFixed(0)}', Icons.account_balance_wallet, Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: _metricCard('Monthly Revenue', '\$${m.monthlyRevenue.toStringAsFixed(0)}', Icons.trending_up, Colors.green)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _metricCard('Monthly Expenses', '\$${m.monthlyExpenses.toStringAsFixed(0)}', Icons.trending_down, Colors.red)),
          const SizedBox(width: 12),
          Expanded(child: _metricCard('Net Profit', '\$${m.netProfit.toStringAsFixed(0)}', Icons.savings, Colors.orange)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _metricCard('Burn Rate', '\$${m.burnRate}', Icons.local_fire_department, Colors.red)),
          const SizedBox(width: 12),
          Expanded(child: _metricCard('Runway', '${m.runway} months', Icons.timer, Colors.green)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _metricCard('Profit Margin', '${m.profitMargin}%', Icons.pie_chart, Colors.teal)),
          const SizedBox(width: 12),
          Expanded(child: _metricCard('Revenue Change', '${m.revenueChange}%', Icons.show_chart, m.revenueChange >= 0 ? Colors.green : Colors.red)),
        ]),
      ],
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _trendChart(List trends) {
    if (trends.isEmpty) return const Center(child: Text('No trends data'));
    final revenueSpots = trends.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.revenue)).toList();
    final expenseSpots = trends.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.expenses)).toList();
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: true),
        lineBarsData: [
          LineChartBarData(spots: revenueSpots, isCurved: true, color: Colors.green, barWidth: 2, dotData: const FlDotData(show: false)),
          LineChartBarData(spots: expenseSpots, isCurved: true, color: Colors.red, barWidth: 2, dotData: const FlDotData(show: false)),
        ],
      ),
    );
  }
}