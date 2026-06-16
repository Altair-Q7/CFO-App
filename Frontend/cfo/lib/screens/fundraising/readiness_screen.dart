import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/providers.dart';

class ReadinessScreen extends ConsumerWidget {
  const ReadinessScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readinessAsync = ref.watch(fundraisingReadinessProvider);
    return Scaffold(
      backgroundColor: AppTheme.baseColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor(context),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('Fundraising Readiness',
            style: TextStyle(
              color: AppTheme.onSurfaceText(context),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            )),
      ),
      body: readinessAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: TextStyle(color: AppTheme.coral))),
        data: (readiness) {
          if (readiness == null) {
            return Center(
                child: Text('No data available',
                    style: TextStyle(
                        color: AppTheme.onSurfaceTextSecondary(context))));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _scoreCard(context, 'Overall Score', readiness.overallScore,
                    AppTheme.navyMid),
                const SizedBox(height: 12),
                _scoreCard(context, 'Financial Health',
                    readiness.financialHealth, AppTheme.emerald),
                const SizedBox(height: 24),
                Text('Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceText(context),
                    )),
                const SizedBox(height: 12),
                if (readiness.breakdown != null)
                  ...readiness.breakdown!.entries.map((e) =>
                      _buildBreakdownItem(context, e.key, e.value)),
                const SizedBox(height: 24),
                Text('Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurfaceText(context),
                    )),
                const SizedBox(height: 12),
                if (readiness.details != null)
                  ...readiness.details!.entries
                      .map((e) => _buildDetailItem(context, e.key, e.value)),
                const SizedBox(height: 32),
                _buildDataRoomButton(context),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _scoreCard(
      BuildContext context, String label, int score, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
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
      child: Column(children: [
        Text('$score',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: color,
            )),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppTheme.onSurfaceTextSecondary(context)
                  : AppTheme.textSecondary,
            )),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: AppTheme.borderColor(context),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ]),
    );
  }

  Widget _buildBreakdownItem(
      BuildContext context, String key, double value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              key.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim(),
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.onSurfaceText(context),
              ),
            ),
          ),
          Text('${value.toStringAsFixed(0)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.onSurfaceText(context),
              )),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, String key, dynamic value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              key.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim(),
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.onSurfaceText(context),
              ),
            ),
          ),
          Text('\$$value',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppTheme.onSurfaceText(context),
              )),
        ],
      ),
    );
  }

  Widget _buildDataRoomButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, '/fundraising/data-room'),
        icon: const Icon(Icons.folder_open_rounded),
        label: const Text('Data Room'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
