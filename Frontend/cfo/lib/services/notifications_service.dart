import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/notification_model.dart';

class NotificationsService {
  final ApiClient _client;
  NotificationsService(this._client);

  Future<Map<String, dynamic>> getNotifications() async {
    final data = await _client.get(ApiConstants.notifications);
    final notifications = (data['notifications'] as List? ?? []).map((e) => NotificationModel.fromJson(e)).toList();
    return {
      'notifications': notifications,
      'unreadCount': data['unreadCount'] ?? 0,
    };
  }

  Future<void> markAsRead(String id) async {
    await _client.patch(ApiConstants.notificationRead(id));
  }

  Future<void> markAllAsRead() async {
    await _client.post(ApiConstants.notificationsMarkAllRead);
  }
}