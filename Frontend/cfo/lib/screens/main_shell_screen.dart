import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'dashboard/founder_dashboard_screen.dart';
import 'dashboard/advisor_dashboard_screen.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'forecasting/forecast_screen.dart';
import 'ai_assistant/chat_screen.dart';
import 'reports/reports_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});
  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    ref.read(notificationsProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider).role;
    final widgets = _getScreensForRole(role);
    
    return Scaffold(
      body: widgets[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0B1F3A),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Forecast'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  List<Widget> _getScreensForRole(String role) {
    switch (role) {
      case 'advisor':
        return [const AdvisorDashboardScreen(), const ForecastScreen(), const AiChatScreen(), const ReportsScreen(), _MoreMenu()];
      case 'admin':
        return [const AdminDashboardScreen(), const ForecastScreen(), const AiChatScreen(), const ReportsScreen(), _MoreMenu()];
      default:
        return [const FounderDashboardScreen(), const ForecastScreen(), const AiChatScreen(), const ReportsScreen(), _MoreMenu()];
    }
  }
}

// Placeholders removed — real screens now used below.

// Placeholder removed — real screen used.

// Placeholder removed — real screen used.

class _MoreMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          ListTile(title: Text('Forecasting'), leading: Icon(Icons.trending_up), onTap: () => Navigator.pushNamed(context, '/forecasting')),
          ListTile(title: Text('AI Assistant'), leading: Icon(Icons.smart_toy), onTap: () => Navigator.pushNamed(context, '/ai-chat')),
          ListTile(title: Text('Reports'), leading: Icon(Icons.receipt_long), onTap: () => Navigator.pushNamed(context, '/reports')),
          ListTile(title: Text('Marketplace'), leading: Icon(Icons.store), onTap: () => Navigator.pushNamed(context, '/marketplace')),
          ListTile(title: Text('Fundraising'), leading: Icon(Icons.volunteer_activism), onTap: () => Navigator.pushNamed(context, '/fundraising')),
          ListTile(title: Text('Notifications'), leading: Icon(Icons.notifications), onTap: () => Navigator.pushNamed(context, '/notifications')),
          ListTile(title: Text('Profile'), leading: Icon(Icons.person), onTap: () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
    );
  }
}