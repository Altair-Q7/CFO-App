// =============================================================================
// AdvisorDashboardScreen — MADI Advisor Client Hub
// =============================================================================
// Advisor view showing:
//   - MADI Briefing card (navy gradient with client portfolio overview)
//   - 3-column KPI row (Active Clients, Upcoming, Rating)
//   - Upcoming Bookings list with client details
//   - Client Health list with runway-based status (Healthy/Watch/Critical)
//   - Recent Activity log
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/madi_presence_indicator.dart';

class AdvisorDashboardScreen extends ConsumerStatefulWidget {
  const AdvisorDashboardScreen({super.key});

  @override
  ConsumerState<AdvisorDashboardScreen> createState() =>
      _AdvisorDashboardScreenState();
}

class _AdvisorDashboardScreenState
    extends ConsumerState<AdvisorDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // Fetch mock advisor metrics
    final data = MockDataService().getMockAdvisorMetrics();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.baseColor(context),
      // AppBar with MADI presence, rating badge, and logout button
      appBar: AppBar(
        backgroundColor:
            isDark ? AppTheme.navyDeep : AppTheme.surfaceColor(context),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(data['advisorName'] ?? 'Advisor Dashboard',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppTheme.textOnDark
                  : AppTheme.onSurfaceText(context),
            )),
        actions: [
          const MadiPresenceIndicator(),
          const SizedBox(width: 4),
          _ratingBadge(data),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildMadiBriefing(),
              const SizedBox(height: 16),
              _buildKpiRow(data),
              const SizedBox(height: 20),
              _buildSectionTitle(
                  'Upcoming Bookings', Icons.calendar_month_rounded),
              const SizedBox(height: 12),
              _buildBookings(data),
              const SizedBox(height: 20),
              _buildSectionTitle('Client Health', Icons.monitor_heart_rounded),
              const SizedBox(height: 12),
              _buildClientHealth(data),
              const SizedBox(height: 20),
              _buildSectionTitle('Recent Activity', Icons.history_rounded),
              const SizedBox(height: 12),
              _buildRecentActivity(data),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  /// Gold-accented rating badge shown in AppBar
  Widget _ratingBadge(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppTheme.gold, size: 14),
          const SizedBox(width: 4),
          Text('${data['rating']}',
              style: const TextStyle(
                  color: AppTheme.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  /// MADI briefing card — navy gradient with portfolio overview
  Widget _buildMadiBriefing() {
    final madiData = MockDataService().getMadiBriefingHealthy();
    final sentences = madiData['sentences'] as List<String>;
    final status = madiData['healthStatus'] as String? ?? 'healthy';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        gradient: AppTheme.navyGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyDeep.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Gold "M" icon
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
                  Text('Client Portfolio Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 2),
                  Text(
                      sentences.isNotEmpty
                          ? sentences.first
                          : 'All clients monitored',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.emerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: AppTheme.emerald.withValues(alpha: 0.3)),
              ),
              child: Text(status.toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.emerald,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  /// Section title with icon — follows MADI gold accent in dark mode
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon,
            size: 18,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.gold
                : AppTheme.navyDeep),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.textOnDark
                    : AppTheme.onSurfaceText(context))),
      ],
    );
  }

  /// Three KPI cards: Active Clients, Upcoming, Rating
  Widget _buildKpiRow(Map<String, dynamic> data) {
    return Row(
      children: [
        _kpiCard('Active Clients', '${data['activeEngagements']}',
            Icons.people_rounded, AppTheme.emerald),
        const SizedBox(width: 10),
        _kpiCard('Upcoming', '${(data['upcomingBookings'] as List).length}',
            Icons.event_rounded, AppTheme.amber),
        const SizedBox(width: 10),
        _kpiCard(
            'Rating', '${data['rating']}', Icons.star_rounded, AppTheme.gold),
      ],
    );
  }

  /// Individual KPI card with icon, value, label
  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderColor(context), width: 0.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.onSurfaceTextSecondary(context)),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  /// Upcoming bookings list with client name, date, time, topic
  Widget _buildBookings(Map<String, dynamic> data) {
    final bookings = data['upcomingBookings'] as List;
    return Column(
      children: bookings.map((b) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(context),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppTheme.borderColor(context), width: 0.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.gold.withValues(alpha: 0.15)
                      : AppTheme.navyDeep.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.event_rounded,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.gold
                        : AppTheme.navyDeep,
                    size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b['client']!,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceText(context))),
                    const SizedBox(height: 2),
                    Text('${b['date']} \u00B7 ${b['time']}',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.onSurfaceTextSecondary(context))),
                    const SizedBox(height: 2),
                    Text('Topic: ${b['topic']}',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.onSurfaceTextSecondary(context))),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Client health cards with status color based on runway remaining
  Widget _buildClientHealth(Map<String, dynamic> data) {
    final health = data['clientHealth'] as List;
    return Column(
      children: health.map((c) {
        Color statusColor;
        String statusLabel;
        final runway = c['runway'] as int;
        if (runway >= 12) {
          statusColor = AppTheme.emerald;
          statusLabel = 'Healthy';
        } else if (runway >= 6) {
          statusColor = AppTheme.amber;
          statusLabel = 'Watch';
        } else {
          statusColor = AppTheme.coral;
          statusLabel = 'Critical';
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(context),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppTheme.borderColor(context), width: 0.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  runway >= 12
                      ? Icons.health_and_safety_rounded
                      : runway >= 6
                          ? Icons.warning_amber_rounded
                          : Icons.error_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['name']!,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceText(context))),
                    const SizedBox(height: 2),
                    Text('$runway months runway',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.onSurfaceTextSecondary(context))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Recent activity list with client and action description
  Widget _buildRecentActivity(Map<String, dynamic> data) {
    final activities = data['recentActivity'] as List;
    return Column(
      children: activities.map((a) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(context),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppTheme.borderColor(context), width: 0.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.gold.withValues(alpha: 0.15)
                      : AppTheme.navyMid.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.history_rounded,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.gold
                        : AppTheme.navyMid,
                    size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['client']!,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceText(context))),
                    const SizedBox(height: 2),
                    Text('${a['action']} \u00B7 ${a['daysAgo']} days ago',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.onSurfaceTextSecondary(context))),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
