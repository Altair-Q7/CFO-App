import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/madi_presence_indicator.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

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
        title: Text('Financial Reports',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMadiBriefing(context),
          const SizedBox(height: 16),
          _reportCard(
            context,
            'Profit & Loss Statement',
            'Revenue, expenses, and net profit',
            Icons.assessment_rounded,
            AppTheme.emerald,
            '/reports/pnl',
          ),
          _reportCard(
            context,
            'Balance Sheet',
            'Assets, liabilities, and equity',
            Icons.account_balance_rounded,
            AppTheme.navyMid,
            '/reports/balance-sheet',
          ),
          _reportCard(
            context,
            'Cash Flow Statement',
            'Operating, investing, and financing',
            Icons.monetization_on_rounded,
            AppTheme.amber,
            '/reports/cash-flow',
          ),
        ],
      ),
    );
  }

  Widget _buildMadiBriefing(BuildContext context) {
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                  child: Text('M',
                      style: TextStyle(
                        color: AppTheme.gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MADI Reports',
                      style: TextStyle(
                        color: AppTheme.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      )),
                  const SizedBox(height: 2),
                  Text('Select a report to view detailed financial statements.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportCard(BuildContext context, String title, String subtitle,
      IconData icon, Color color, String route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.pushNamed(context, route),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurfaceText(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.onSurfaceTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.onSurfaceTextMuted(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
