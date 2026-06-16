import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/providers.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final isDark = currentTheme == ThemeMode.dark ||
        (currentTheme == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final bg = isDark ? AppTheme.darkBase : AppTheme.lightBase;
    final textPrimary = isDark ? AppTheme.textOnDark : AppTheme.onSurfaceText(context);
    final textSecondary = isDark ? AppTheme.textOnDarkMuted : AppTheme.onSurfaceTextSecondary(context);
    final cardBg = isDark ? AppTheme.darkElevated : AppTheme.lightSurface;
    final borderCol = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    final roles = [
      {'role': 'founder', 'icon': Icons.business, 'title': 'Founder', 'desc': 'Access your financial dashboard, forecasts, and AI assistant'},
      {'role': 'advisor', 'icon': Icons.analytics, 'title': 'Advisor', 'desc': 'Manage client portfolios and consulting sessions'},
      {'role': 'admin', 'icon': Icons.admin_panel_settings, 'title': 'Admin', 'desc': 'Manage platform, verify advisors, and system analytics'},
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.navyDeep : AppTheme.surfaceColor(context),
        foregroundColor: isDark ? AppTheme.textOnDark : AppTheme.onSurfaceText(context),
        elevation: 0,
        centerTitle: true,
        title: const Text('Select Your Role'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text('Choose your role to continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
            const SizedBox(height: 24),
            ...roles.map((r) => Card(
              color: cardBg,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: borderCol, width: 0.5),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Icon(r['icon'] as IconData, size: 40, color: AppTheme.iconOnSurface(context)),
                title: Text(r['title'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary)),
                subtitle: Text(r['desc'] as String, style: TextStyle(color: textSecondary)),
                trailing: Icon(Icons.arrow_forward_ios, color: textSecondary, size: 16),
                onTap: () {
                  ref.read(authProvider.notifier).setRole(r['role'] as String);
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
            )),
          ],
        ),
      ),
    );
  }
}
