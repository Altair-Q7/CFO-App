import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/mock_data_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final data = MockDataService().getMockAdminMetrics();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Admin Platform'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('Live',
                    style: TextStyle(
                        color: AppTheme.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildKpiGrid(data),
              const SizedBox(height: 16),
              _buildGrowthHint(data),
              const SizedBox(height: 20),
              _buildAlerts(data),
              const SizedBox(height: 20),
              _buildPlanDistribution(data),
              const SizedBox(height: 20),
              _buildSectionTitle(
                  'Advisor Pipeline', Icons.verified_user_rounded),
              const SizedBox(height: 12),
              _buildAdvisorPipeline(data),
              const SizedBox(height: 20),
              _buildSectionTitle('Recent Signups', Icons.people_rounded),
              const SizedBox(height: 12),
              _buildRecentSignups(data),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildKpiGrid(Map<String, dynamic> data) {
    final revValue = data['platformRevenue'] as int;
    final items = <Map<String, dynamic>>[
      {
        'label': 'Total Founders',
        'value': '${data['totalFounders']}',
        'icon': Icons.people_rounded,
        'color': AppTheme.primary,
        'subtitle': '${data['activeThisMonth']} active this month',
      },
      {
        'label': 'Total Advisors',
        'value': '${data['totalAdvisors']}',
        'icon': Icons.verified_user_rounded,
        'color': AppTheme.info,
        'subtitle': '${data['totalBookings']} bookings',
      },
      {
        'label': 'Platform Revenue',
        'value': '₹${(revValue / 100000).toStringAsFixed(1)}L',
        'icon': Icons.trending_up_rounded,
        'color': AppTheme.success,
        'subtitle': '+${data['platformRevenueChange']}% this month',
      },
      {
        'label': 'Avg Session',
        'value': '${data['avgSessionMinutes']}m',
        'icon': Icons.timer_rounded,
        'color': AppTheme.warning,
        'subtitle': 'Uptime ${data['uptime']}%',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: items.length,
      itemBuilder: (ctx, i) {
        final item = items[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item['icon'] as IconData,
                    color: item['color'] as Color, size: 16),
              ),
              const Spacer(),
              Text(item['value']!,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: item['color'] as Color)),
              const SizedBox(height: 2),
              Text(item['label']!,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 1),
              Text(item['subtitle']!,
                  style:
                      const TextStyle(fontSize: 10, color: AppTheme.textHint)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrowthHint(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.success.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_graph_rounded, color: AppTheme.success, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Platform growing at +${data['platformRevenueChange']}% revenue this month — ${data['totalFounders']} total founders onboarded',
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts(Map<String, dynamic> data) {
    final alerts = data['alerts'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            'Platform Alerts', Icons.notifications_active_rounded),
        const SizedBox(height: 12),
        ...alerts.map((a) {
          Color color;
          switch (a['type']) {
            case 'warning':
              color = AppTheme.warning;
              break;
            case 'success':
              color = AppTheme.success;
              break;
            default:
              color = AppTheme.info;
          }
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Icon(
                  a['type'] == 'warning'
                      ? Icons.warning_amber_rounded
                      : a['type'] == 'success'
                          ? Icons.check_circle_rounded
                          : Icons.info_rounded,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(a['message']!,
                      style: TextStyle(fontSize: 12, color: color)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPlanDistribution(Map<String, dynamic> data) {
    final dist = data['planDistribution'] as Map<String, dynamic>;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Plan Distribution', Icons.subscriptions_rounded),
          const SizedBox(height: 16),
          Row(
            children: [
              _planTile('Premium', '${dist['premium']}', AppTheme.accentGold),
              const SizedBox(width: 12),
              _planTile('Standard', '${dist['standard']}', AppTheme.primary),
              const SizedBox(width: 12),
              _planTile('Basic', '${dist['basic']}', AppTheme.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Flexible(
                    flex: dist['premium'] as int,
                    child: Container(color: AppTheme.accentGold),
                  ),
                  Flexible(
                    flex: dist['standard'] as int,
                    child: Container(color: AppTheme.primary),
                  ),
                  Flexible(
                    flex: dist['basic'] as int,
                    child: Container(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planTile(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAdvisorPipeline(Map<String, dynamic> data) {
    final advisors = data['advisorPipeline'] as List;
    return Column(
      children: advisors.map((a) {
        Color statusColor;
        switch (a['status']) {
          case 'Verified':
            statusColor = AppTheme.success;
            break;
          case 'Pending':
            statusColor = AppTheme.warning;
            break;
          case 'Suspended':
            statusColor = AppTheme.error;
            break;
          default:
            statusColor = AppTheme.textHint;
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['name']!,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text('${a['clients']} clients · ★ ${a['rating']}',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(a['status']!,
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

  Widget _buildRecentSignups(Map<String, dynamic> data) {
    final signups = data['recentSignups'] as List;
    return Column(
      children: signups.map((s) {
        Color planColor;
        switch (s['plan']) {
          case 'Premium':
          case 'Pro':
            planColor = AppTheme.accentGold;
            break;
          case 'Standard':
            planColor = AppTheme.primary;
            break;
          default:
            planColor = AppTheme.textSecondary;
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
                  color: (s['role'] == 'advisor'
                          ? AppTheme.info
                          : AppTheme.success)
                      .withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  s['role'] == 'advisor'
                      ? Icons.verified_user_rounded
                      : Icons.business_rounded,
                  color:
                      s['role'] == 'advisor' ? AppTheme.info : AppTheme.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['name']!,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                        '${s['daysAgo']} day${s['daysAgo'] == 1 ? '' : 's'} ago',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: planColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(s['plan']!,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: planColor)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
