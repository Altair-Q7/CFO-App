import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationsProvider.notifier).markAllAsRead(),
            child: const Text('Mark All Read'),
          ),
        ],
      ),
      body: notifState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          final notifications = data['notifications'] as List;
          final unread = data['unreadCount'] ?? 0;
          if (notifications.isEmpty) return const Center(child: Text('No notifications'));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (unread > 0) Padding(
                padding: const EdgeInsets.all(8),
                child: Text('Unread: $unread', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: notifications.length,
                  itemBuilder: (ctx, i) {
                    final n = notifications[i];
                    return Card(
                      color: n.read ? null : Colors.blue[50],
                      child: ListTile(
                        leading: Icon(n.read ? Icons.notifications_none : Icons.notifications_active, color: n.read ? Colors.grey : Colors.orange),
                        title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.normal : FontWeight.bold)),
                        subtitle: Text(n.message),
                        trailing: n.read ? null : CircleAvatar(radius: 8, backgroundColor: Colors.red),
                        onTap: () => ref.read(notificationsProvider.notifier).markRead(n.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}