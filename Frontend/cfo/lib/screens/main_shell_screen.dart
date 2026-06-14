import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../providers/providers.dart';
import 'dashboard/founder_dashboard_screen.dart';
import 'dashboard/advisor_dashboard_screen.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'forecasting/forecast_screen.dart';
import 'ai_assistant/chat_screen.dart';
import 'reports/reports_screen.dart';
import 'profile/profile_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _currentIndex = 0;

  // Reset tab index when role changes (e.g. after re-login)
  String _lastRole = '';

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final role = auth.role;

    // Reset to tab 0 if role changed
    if (_lastRole != role) {
      _lastRole = role;
      _currentIndex = 0;
    }

    final config = _getConfig(role);
    final screens = config['screens'] as List<Widget>;
    final tabs = config['tabs'] as List<Map<String, dynamic>>;

    return Scaffold(
      // Each screen is responsible for its own AppBar.
      // Shell only provides the bottom nav and logout.
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabs.length, (i) {
                final tab = tabs[i];
                final isSelected = _currentIndex == i;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (tab['action'] != null) {
                      (tab['action'] as VoidCallback)();
                    } else {
                      setState(() => _currentIndex = i);
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          size: 22,
                          color:
                              isSelected ? AppTheme.primary : AppTheme.textHint,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tab['label'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getConfig(String role) {
    switch (role) {
      case 'advisor':
        return {
          'screens': [
            const AdvisorDashboardScreen(),
            const AiChatScreen(),
            const ProfileScreen(),
            _buildLogoutScreen(),
          ],
          'tabs': [
            {'icon': Icons.people_rounded, 'label': 'Clients'},
            {'icon': Icons.smart_toy_rounded, 'label': 'AI Tools'},
            {'icon': Icons.person_rounded, 'label': 'Profile'},
            {
              'icon': Icons.logout_rounded,
              'label': 'Logout',
              'action': _logout,
            },
          ],
        };
      case 'admin':
        return {
          'screens': [
            const AdminDashboardScreen(),
            const ReportsScreen(),
            const ProfileScreen(),
            _buildLogoutScreen(),
          ],
          'tabs': [
            {'icon': Icons.analytics_rounded, 'label': 'Platform'},
            {'icon': Icons.bar_chart_rounded, 'label': 'Reports'},
            {'icon': Icons.person_rounded, 'label': 'Profile'},
            {
              'icon': Icons.logout_rounded,
              'label': 'Logout',
              'action': _logout,
            },
          ],
        };
      default: // founder
        return {
          'screens': [
            const FounderDashboardScreen(),
            const ForecastScreen(),
            const AiChatScreen(),
            const ReportsScreen(),
            _buildMoreMenu(),
          ],
          'tabs': [
            {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
            {'icon': Icons.trending_up_rounded, 'label': 'Forecast'},
            {'icon': Icons.smart_toy_rounded, 'label': 'AI'},
            {'icon': Icons.receipt_long_rounded, 'label': 'Reports'},
            {'icon': Icons.menu_rounded, 'label': 'More'},
          ],
        };
    }
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildLogoutScreen() {
    // Never actually shown — logout tab triggers action directly
    return const SizedBox.shrink();
  }

  Widget _buildMoreMenu() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuCard(
            Icons.store_rounded,
            'Marketplace',
            'Find and book CFO advisors',
            AppTheme.info,
            () => Navigator.pushNamed(context, '/marketplace'),
          ),
          _menuCard(
            Icons.volunteer_activism_rounded,
            'Fundraising',
            'Readiness score & data room',
            AppTheme.success,
            () => Navigator.pushNamed(context, '/fundraising'),
          ),
          _menuCard(
            Icons.notifications_rounded,
            'Notifications',
            'Alerts and updates',
            AppTheme.warning,
            () => Navigator.pushNamed(context, '/notifications'),
          ),
          _menuCard(
            Icons.person_rounded,
            'Profile',
            'Account & company info',
            AppTheme.primary,
            () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(IconData icon, String title, String subtitle, Color color,
      VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          )),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          )),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppTheme.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
