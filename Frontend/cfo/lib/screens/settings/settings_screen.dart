import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final userName = auth.name?.isNotEmpty == true ? auth.name! : 'User';
    final userEmail = auth.email?.isNotEmpty == true ? auth.email! : 'user@example.com';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.textOnDark : AppTheme.textPrimary;

    return Scaffold(
      backgroundColor: AppTheme.baseColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor(context),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('Settings', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary,
        )),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('ACCOUNT'),
          const SizedBox(height: 8),
          _settingsTile(context,
            icon: Icons.person_outline_rounded,
            title: userName,
            subtitle: userEmail,
            color: AppTheme.iconOnSurface(context),
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          _settingsTile(context,
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            subtitle: 'Name, email, company details',
            color: AppTheme.iconOnSurface(context),
            onTap: () => Navigator.pushNamed(context, '/profile/edit'),
          ),
          const SizedBox(height: 24),

          _sectionHeader('PREFERENCES'),
          const SizedBox(height: 8),
          _settingsTile(context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Push alerts, email digests',
            color: AppTheme.amber,
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          _settingsTile(context,
            icon: Icons.currency_rupee_rounded,
            title: 'Currency',
            subtitle: 'Indian Rupee (\u20B9)',
            color: AppTheme.emerald,
            onTap: () {},
          ),
          const SizedBox(height: 24),

          _sectionHeader('APPEARANCE'),
          const SizedBox(height: 8),
          _themeOption(context, ref, ThemeMode.light, Icons.light_mode_rounded, 'Light'),
          _themeOption(context, ref, ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
          _themeOption(context, ref, ThemeMode.system, Icons.settings_brightness_rounded, 'System'),
          const SizedBox(height: 24),

          _sectionHeader('ABOUT'),
          const SizedBox(height: 8),
          _settingsTile(context,
            icon: Icons.info_outline_rounded,
            title: 'The Scalable CFO',
            subtitle: 'Version 1.0.0',
            color: AppTheme.textSecondary,
            onTap: () {},
          ),
          _settingsTile(context,
            icon: Icons.description_outlined,
            title: 'Open Source Licenses',
            subtitle: 'Third-party software notices',
            color: AppTheme.textSecondary,
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'The Scalable CFO',
              applicationVersion: '1.0.0',
            ),
          ),
          const SizedBox(height: 32),

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

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(title, style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AppTheme.textSecondary,
      )),
    );
  }

  Widget _settingsTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.textOnDark
                            : AppTheme.textPrimary,
                      )),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.textOnDarkMuted
                            : AppTheme.textSecondary,
                      )),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _themeOption(BuildContext context, WidgetRef ref, ThemeMode value, IconData icon, String label) {
    final current = ref.watch(themeProvider);
    final selected = current == value;
    final surface = AppTheme.surfaceColor(context);
    final border = AppTheme.borderColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.textOnDark : AppTheme.textPrimary;
    final textSecondary = isDark ? AppTheme.textOnDarkMuted : AppTheme.textSecondary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppTheme.gold : border,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
          onTap: () => ref.read(themeProvider.notifier).setTheme(value),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.gold.withValues(alpha: 0.15)
                        : textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: selected ? AppTheme.gold : textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(label, style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppTheme.gold : textPrimary,
                  )),
                ),
                if (selected)
                  Container(
                    width: 22, height: 22,
                    decoration: const BoxDecoration(
                      color: AppTheme.gold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
