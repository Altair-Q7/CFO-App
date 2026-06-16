import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/providers.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/madi_logo.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final role = auth.role;
    final name = auth.name ?? 'User';
    final email = auth.email ?? '';
    final initials = name.split(' ').map((s) => s[0]).take(2).join();

    final mock = MockDataService();
    final profile = mock.getMockProfile();
    final company = profile['company'] as Map<String, dynamic>;

    final roleLabel = role.toUpperCase();
    final roleColor = switch (role) {
      'advisor' => AppTheme.amber,
      'admin' => AppTheme.gold,
      _ => AppTheme.emerald,
    };

    return Scaffold(
      backgroundColor: AppTheme.baseColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor(context),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('Profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceText(context),
            )),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.navyGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const MadiLogo(size: 48),
                const SizedBox(height: 16),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
                const SizedBox(height: 16),
                Text(name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 4),
                Text(email,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    )),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(roleLabel,
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (role == 'founder') ...[
            _sectionHeader(context, 'COMPANY'),
            const SizedBox(height: 8),
            _infoCard(context, [
              _infoRow(context, Icons.business_rounded, 'Company',
                  company['name'] ?? 'N/A'),
              _infoRow(context, Icons.category_rounded, 'Industry',
                  company['industry'] ?? 'N/A'),
              _infoRow(context, Icons.trending_up_rounded, 'Monthly Revenue',
                  '\u20B9${(company['monthly_revenue'] as num? ?? 0).toStringAsFixed(0)}'),
              _infoRow(context, Icons.trending_down_rounded, 'Monthly Expenses',
                  '\u20B9${(company['monthly_expenses'] as num? ?? 0).toStringAsFixed(0)}'),
              _infoRow(context, Icons.people_rounded, 'Employees',
                  '${company['employees'] ?? 0}'),
            ]),
          ],
          if (role == 'advisor') ...[
            _sectionHeader(context, 'ADVISOR INFO'),
            const SizedBox(height: 8),
            _infoCard(context, [
              _infoRow(context, Icons.star_rounded, 'Rating', '4.9'),
              _infoRow(context, Icons.people_rounded, 'Total Clients', '8'),
              _infoRow(context, Icons.calendar_month_rounded,
                  'Active Engagements', '5'),
              _infoRow(context, Icons.check_circle_rounded,
                  'Completed Sessions', '47'),
            ]),
          ],
          if (role == 'admin') ...[
            _sectionHeader(context, 'PLATFORM OVERVIEW'),
            const SizedBox(height: 8),
            _infoCard(context, [
              _infoRow(context, Icons.people_rounded, 'Total Founders', '342'),
              _infoRow(
                  context, Icons.verified_user_rounded, 'Total Advisors', '28'),
              _infoRow(context, Icons.business_rounded, 'Companies', '156'),
              _infoRow(context, Icons.trending_up_rounded, 'Platform Revenue',
                  '\u20B912.5L'),
            ]),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/profile/edit'),
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.gold
                    : AppTheme.navyDeep,
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.gold
                      : AppTheme.navyDeep,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: const Text('Settings'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.onSurfaceTextSecondary(context),
                side: BorderSide(color: AppTheme.borderColor(context)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.coral,
                side: const BorderSide(color: AppTheme.coral),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: isDark ? AppTheme.textOnDarkMuted : AppTheme.textSecondary,
        ));
  }

  Widget _infoCard(BuildContext context, List<Widget> rows) {
    return Container(
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
      child: Column(children: rows),
    );
  }

  Widget _infoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.onSurfaceTextSecondary(context)),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.onSurfaceTextSecondary(context),
              )),
          const Spacer(),
          Text(value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceText(context),
              )),
        ],
      ),
    );
  }
}
