// =============================================================================
// MainShellScreen — Role-aware bottom navigation shell
// =============================================================================
// Provides the bottom navigation bar for all three roles (founder, advisor,
// admin). Each role gets role-appropriate tabs. Logout is NOT a navigation
// tab — it lives in Settings and Profile screens only.
// =============================================================================

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
  String _lastRole = '';

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final role = auth.role;

    // Reset to tab 0 when role changes (e.g. after re-login)
    if (_lastRole != role) {
      _lastRole = role;
      _currentIndex = 0;
    }

    final config = _getConfig(role);
    final screens = config['screens'] as List<Widget>;
    final tabs = config['tabs'] as List<Map<String, dynamic>>;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
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
                  onTap: () => setState(() => _currentIndex = i),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.gold.withValues(alpha: 0.15)
                              : AppTheme.navyDeep.withValues(alpha: 0.1))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          size: 22,
                          color: isSelected
                              ? AppTheme.iconOnSurface(context)
                              : AppTheme.onSurfaceTextSecondary(context),
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
                                ? AppTheme.iconOnSurface(context)
                                : AppTheme.onSurfaceTextSecondary(context),
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

  /// Returns the screens/tabs config for the given role.
  /// Logout is NOT a navigation tab — it's accessible from Settings/Profile.
  Map<String, dynamic> _getConfig(String role) {
    switch (role) {
      case 'advisor':
        return {
          'screens': [
            const AdvisorDashboardScreen(),
            const AiChatScreen(),
            const ProfileScreen(),
          ],
          'tabs': [
            {'icon': Icons.people_rounded, 'label': 'Clients'},
            {'icon': Icons.smart_toy_rounded, 'label': 'AI Tools'},
            {'icon': Icons.person_rounded, 'label': 'Profile'},
          ],
        };
      case 'admin':
        return {
          'screens': [
            const AdminDashboardScreen(),
            const ReportsScreen(),
            const ProfileScreen(),
          ],
          'tabs': [
            {'icon': Icons.analytics_rounded, 'label': 'Platform'},
            {'icon': Icons.bar_chart_rounded, 'label': 'Reports'},
            {'icon': Icons.person_rounded, 'label': 'Profile'},
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

  /// Founder's "More" menu with secondary navigation items
  Widget _buildMoreMenu() {
    return Scaffold(
      backgroundColor: AppTheme.baseColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor(context),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('More',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceText(context),
            )),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuCard(
            Icons.store_rounded,
            'Marketplace',
            'Find and book CFO advisors',
            AppTheme.navyMid,
            () => Navigator.pushNamed(context, '/marketplace'),
          ),
          _menuCard(
            Icons.volunteer_activism_rounded,
            'Fundraising',
            'Readiness score & data room',
            AppTheme.emerald,
            () => Navigator.pushNamed(context, '/fundraising'),
          ),
          _menuCard(
            Icons.notifications_rounded,
            'Notifications',
            'Alerts and updates',
            AppTheme.amber,
            () => Navigator.pushNamed(context, '/notifications'),
          ),
          _menuCard(
            Icons.person_rounded,
            'Profile',
            'Account & company info',
            AppTheme.iconOnSurface(context),
            () => Navigator.pushNamed(context, '/profile'),
          ),
          const SizedBox(height: 4),
          _menuCard(
            Icons.settings_rounded,
            'Settings',
            'Preferences & app config',
            AppTheme.onSurfaceTextSecondary(context),
            () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
    );
  }

  /// Standardized menu card widget with icon, title, subtitle, chevron
  Widget _menuCard(IconData icon, String title, String subtitle, Color color,
      VoidCallback onTap) {
    final surface = AppTheme.surfaceColor(context);
    final border = AppTheme.borderColor(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                    color: color.withValues(alpha: 0.1),
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
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceText(context),
                          )),
                      const SizedBox(height: 2),
                      Text(subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.onSurfaceTextSecondary(context),
                          )),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppTheme.onSurfaceTextSecondary(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
