import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/role_selection_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/main_shell_screen.dart';
import 'screens/dashboard/founder_dashboard_screen.dart';
import 'screens/dashboard/advisor_dashboard_screen.dart';
import 'screens/dashboard/admin_dashboard_screen.dart';
import 'screens/forecasting/forecast_screen.dart';
import 'screens/ai_assistant/chat_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/reports/pnl_report_screen.dart';
import 'screens/reports/balance_sheet_screen.dart';
import 'screens/reports/cash_flow_screen.dart';
import 'screens/marketplace/advisor_list_screen.dart';
import 'screens/marketplace/advisor_detail_screen.dart';
import 'screens/marketplace/booking_screen.dart';
import 'screens/fundraising/readiness_screen.dart';
import 'screens/fundraising/data_room_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';

class CfoApp extends ConsumerWidget {
  const CfoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'The Scalable CFO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (ctx) => const SplashScreen(),
        '/login': (ctx) => const LoginScreen(),
        '/signup': (ctx) => const SignupScreen(),
        '/forgot-password': (ctx) => const ForgotPasswordScreen(),
        '/role-selection': (ctx) => const RoleSelectionScreen(),
        '/onboarding': (ctx) => const OnboardingScreen(),
        '/home': (ctx) => const MainShellScreen(),
        '/founder-dashboard': (ctx) => const FounderDashboardScreen(),
        '/advisor-dashboard': (ctx) => const AdvisorDashboardScreen(),
        '/admin-dashboard': (ctx) => const AdminDashboardScreen(),
        '/forecasting': (ctx) => const ForecastScreen(),
        '/ai-chat': (ctx) => const AiChatScreen(),
        '/reports': (ctx) => const ReportsScreen(),
        '/reports/pnl': (ctx) => const PnlReportScreen(),
        '/reports/balance-sheet': (ctx) => const BalanceSheetScreen(),
        '/reports/cash-flow': (ctx) => const CashFlowScreen(),
        '/marketplace': (ctx) => const AdvisorListScreen(),
        '/marketplace/advisor-detail': (ctx) => const AdvisorDetailScreen(),
        '/marketplace/booking': (ctx) => const BookingScreen(),
        '/fundraising': (ctx) => const ReadinessScreen(),
        '/fundraising/data-room': (ctx) => const DataRoomScreen(),
        '/notifications': (ctx) => const NotificationsScreen(),
        '/profile': (ctx) => const ProfileScreen(),
        '/profile/edit': (ctx) => const EditProfileScreen(),
      },
    );
  }
}
