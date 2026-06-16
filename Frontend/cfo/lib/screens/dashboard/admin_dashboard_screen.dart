// =============================================================================
// AdminDashboardScreen — MADI Operations Center (Admin View)
// =============================================================================
// Full admin platform overview showing:
//   - Platform Revenue (large hero metric on navy gradient)
//   - 4 KPI grid: Total Founders, Total Advisors, Bookings, Uptime
//   - Revenue Breakdown bar chart (SaaS MRR, Marketplace GMV, Enterprise)
//   - Advisor Pipeline list with status badges (Verified/Pending/Suspended)
//   - Platform Alerts (warning/success/info)
//   - Recent Signups with plan badges
// =============================================================================

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/madi_presence_indicator.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // Fetch mock admin platform metrics
    final data = MockDataService().getMockAdminMetrics();

    return Scaffold(
      backgroundColor: AppTheme.baseColor(context),
      // Dark navy AppBar — command center feel, not a consumer app
      appBar: AppBar(
        backgroundColor: AppTheme.navyDeep,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Operations Center',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                )),
            Text('The Scalable CFO \u00B7 Admin',
                style: TextStyle(
                  color: AppTheme.textOnDarkMuted,
                  fontSize: 11,
                )),
          ],
        ),
        actions: [
          const MadiPresenceIndicator(),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildRevenueHeader(data),
              _buildKpiGrid(data),
              _buildRevenueBreakdown(data),
              _buildAdvisorPipeline(data),
              _buildAlerts(data),
              _buildRecentSignups(data),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  /// Large header card on navy gradient showing platform MRR
  Widget _buildRevenueHeader(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.navyGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PLATFORM REVENUE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppTheme.onSurfaceTextMuted(context),
              )),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Large revenue figure
              Text(
                '₹${((data['platformRevenue'] as num) / 100000).toStringAsFixed(1)}L',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              // Growth percentage badge
              Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '+${data['platformRevenueChange']}%',
                    style: const TextStyle(
                      color: AppTheme.emerald,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Monthly Recurring Revenue',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.onSurfaceTextMuted(context),
              )),
        ],
      ),
    );
  }

  /// 2x2 grid of KPI cards — each with icon, value, and subtitle
  Widget _buildKpiGrid(Map<String, dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = <Map<String, dynamic>>[
      {
        'label': 'TOTAL FOUNDERS',
        'value': '${data['totalFounders']}',
        'icon': Icons.people_rounded,
        'color': isDark ? AppTheme.gold : AppTheme.navyDeep,
        'subtitle': '${data['activeThisMonth']} active this month',
      },
      {
        'label': 'TOTAL ADVISORS',
        'value': '${data['totalAdvisors']}',
        'icon': Icons.verified_user_rounded,
        'color': isDark ? AppTheme.emerald : AppTheme.navyMid,
        'subtitle': '${data['totalBookings']} bookings',
      },
      {
        'label': 'BOOKINGS',
        'value': '${data['totalBookings']}',
        'icon': Icons.calendar_month_rounded,
        'color': AppTheme.emerald,
        'subtitle': '+${data['bookingsChange']}% this month',
      },
      {
        'label': 'UPTIME',
        'value': '${data['uptime']}%',
        'icon': Icons.monitor_heart_rounded,
        'color': AppTheme.amber,
        'subtitle': 'Avg session ${data['avgSessionMinutes']}m',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.6,
        ),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final item = items[i];
          final color = item['color'] as Color;
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
                    Text(item['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: AppTheme.onSurfaceTextMuted(context),
                        )),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item['icon'] as IconData,
                          color: color, size: 14),
                    ),
                  ],
                ),
                Text(item['value'] as String,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.onSurfaceText(context),
                    )),
                Text(item['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.onSurfaceTextSecondary(context),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Three horizontal bars showing SaaS MRR, Marketplace GMV, Enterprise split
  Widget _buildRevenueBreakdown(Map<String, dynamic> data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalRevenue = data['platformRevenue'] as int;
    final breakdown = [
      {
        'label': 'SaaS MRR',
        'value': totalRevenue * 0.65,
        'color': isDark ? AppTheme.gold : AppTheme.navyDeep
      },
      {
        'label': 'Marketplace GMV',
        'value': totalRevenue * 0.22,
        'color': AppTheme.emerald
      },
      {
        'label': 'Enterprise',
        'value': totalRevenue * 0.13,
        'color': AppTheme.amber
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
          Text('REVENUE BREAKDOWN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppTheme.onSurfaceTextSecondary(context),
              )),
          const SizedBox(height: 16),
          ...breakdown.map((b) {
            final label = b['label'] as String;
            final value = b['value'] as double;
            final color = b['color'] as Color;
            final pct = (value / totalRevenue * 100).toStringAsFixed(0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.onSurfaceText(context),
                          )),
                      Text('\u20B9${(value / 100000).toStringAsFixed(1)}L',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceText(context),
                          )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Colored progress bar for each revenue stream
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value / totalRevenue,
                      backgroundColor: AppTheme.borderColor(context),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('$pct% of total',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.onSurfaceTextMuted(context),
                      )),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Advisor list with status badges (Verified = emerald, Pending = amber, Suspended = coral)
  Widget _buildAdvisorPipeline(Map<String, dynamic> data) {
    final advisors = data['advisorPipeline'] as List;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('ADVISOR PIPELINE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppTheme.onSurfaceTextSecondary(context),
                )),
          ),
          ...advisors.map((a) {
            Color statusColor;
            switch (a['status']) {
              case 'Verified':
                statusColor = AppTheme.emerald;
                break;
              case 'Pending':
                statusColor = AppTheme.amber;
                break;
              case 'Suspended':
                statusColor = AppTheme.coral;
                break;
              default:
                statusColor = AppTheme.onSurfaceTextMuted(context);
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
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
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.gold.withValues(alpha: 0.15)
                          : AppTheme.navyDeep.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.person_rounded,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.gold
                            : AppTheme.navyDeep,
                        size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a['name'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppTheme.textOnDark
                                  : AppTheme.onSurfaceText(context),
                            )),
                        const SizedBox(height: 2),
                        Text(
                            '${a['clients']} clients \u00B7 \u2605 ${a['rating']}',
                            style: TextStyle(
                                fontSize: 11,
                                color:
                                    AppTheme.onSurfaceTextSecondary(context))),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(a['status'] as String,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Alert items with color-coded backgrounds (warning=amber, success=emerald, info=gold)
  Widget _buildAlerts(Map<String, dynamic> data) {
    final alerts = data['alerts'] as List;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('PLATFORM ALERTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppTheme.onSurfaceTextSecondary(context),
                )),
          ),
          ...alerts.map((a) {
            Color color;
            IconData icon;
            switch (a['type']) {
              case 'warning':
                color = AppTheme.amber;
                icon = Icons.warning_amber_rounded;
                break;
              case 'success':
                color = AppTheme.emerald;
                icon = Icons.check_circle_rounded;
                break;
              default:
                color = Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.gold
                    : AppTheme.navyMid;
                icon = Icons.info_rounded;
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(a['message'] as String,
                        style: TextStyle(fontSize: 12, color: color)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Recent signups with role icons and plan badges (Premium/Pro=gold, Standard=white)
  Widget _buildRecentSignups(Map<String, dynamic> data) {
    final signups = data['recentSignups'] as List;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('RECENT SIGNUPS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppTheme.onSurfaceTextSecondary(context),
                )),
          ),
          ...signups.map((s) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            Color planColor;
            switch (s['plan']) {
              case 'Premium':
              case 'Pro':
                planColor = AppTheme.gold;
                break;
              case 'Standard':
                planColor = isDark ? AppTheme.textOnDark : AppTheme.navyDeep;
                break;
              default:
                planColor = AppTheme.onSurfaceTextSecondary(context);
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
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
              child: Row(
                children: [
                  // Role-specific icon container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (s['role'] == 'advisor'
                              ? AppTheme.navyMid
                              : AppTheme.emerald)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      s['role'] == 'advisor'
                          ? Icons.verified_user_rounded
                          : Icons.business_rounded,
                      color: s['role'] == 'advisor'
                          ? (isDark ? AppTheme.gold : AppTheme.navyMid)
                          : AppTheme.emerald,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['name'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurfaceText(context),
                            )),
                        const SizedBox(height: 2),
                        Text(
                          '${s['daysAgo']} day${s['daysAgo'] == 1 ? '' : 's'} ago',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.onSurfaceTextSecondary(context)),
                        ),
                      ],
                    ),
                  ),
                  // Plan badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: planColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(s['plan'] as String,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: planColor)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
