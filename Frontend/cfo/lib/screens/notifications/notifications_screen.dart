import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/mock_data_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _mock = MockDataService();
  late Map<String, dynamic> _data;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _data = _mock.getMockNotifications();
    _initialized = true;
  }

  void _markAllRead() {
    setState(() {
      for (final n in _data['notifications']) {
        n.read = true;
      }
      _data['unreadCount'] = 0;
    });
  }

  void _markRead(dynamic n) {
    setState(() {
      n.read = true;
      _data['unreadCount'] = (_data['unreadCount'] as int) - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _data['notifications'] as List;
    final unread = _data['unreadCount'] as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark All Read'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (unread > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    color: AppTheme.info.withOpacity(0.08),
                    child: Text(
                      '$unread unread notification${unread > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: AppTheme.info,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (ctx, i) {
                      final n = notifications[i];
                      return _buildNotificationCard(n);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNotificationCard(dynamic n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:
            !n.read ? Border.all(color: AppTheme.info.withOpacity(0.2)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: n.read
                  ? AppTheme.textHint.withOpacity(0.08)
                  : _typeColor(n.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _typeIcon(n.type),
              color: n.read ? AppTheme.textHint : _typeColor(n.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  n.title,
                  style: TextStyle(
                    fontWeight: n.read ? FontWeight.normal : FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  n.message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _timeAgo(n.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textHint,
                  ),
                ),
              ],
            ),
          ),
          if (!n.read)
            GestureDetector(
              onTap: () => _markRead(n),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.info,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'warning':
        return AppTheme.warning;
      case 'success':
        return AppTheme.success;
      case 'error':
        return AppTheme.error;
      default:
        return AppTheme.info;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'success':
        return Icons.check_circle_rounded;
      case 'error':
        return Icons.error_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.parse(dateStr);
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }
}
