import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/madi_presence_indicator.dart';

class AdvisorListScreen extends StatelessWidget {
  const AdvisorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final advisors = MockDataService().getMockAdvisors();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.baseColor(context),
      appBar: AppBar(
        backgroundColor:
            isDark ? AppTheme.navyDeep : AppTheme.surfaceColor(context),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('CFO Marketplace',
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: advisors.length,
        itemBuilder: (ctx, i) {
          final a = advisors[i];
          final isAvailable = a.availability == 'Available';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor(ctx),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor(ctx), width: 0.5),
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
                onTap: () => Navigator.pushNamed(
                    context, '/marketplace/advisor-detail',
                    arguments: a.id),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.navyGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            a.name.split(' ').map((s) => s[0]).take(2).join(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurfaceText(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${a.specialization} \u2022 ${a.region}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.onSurfaceTextSecondary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 14, color: AppTheme.gold),
                                const SizedBox(width: 4),
                                Text(
                                  a.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.gold),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${a.experience} yrs',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.onSurfaceTextSecondary(
                                          context)),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$${a.pricePerHour}/hr',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppTheme.gold
                                        : AppTheme.navyDeep,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? AppTheme.emerald.withValues(alpha: 0.1)
                              : AppTheme.onSurfaceTextMuted(context)
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : 'Busy',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isAvailable
                                ? AppTheme.emerald
                                : AppTheme.onSurfaceTextMuted(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
