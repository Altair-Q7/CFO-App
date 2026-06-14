import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/notification_model.dart';
import '../services/mock_data_service.dart';

class NotificationsService {
  final ApiClient _client;
  final bool _useMock;

  NotificationsService(this._client, {bool useMock = true})
      : _useMock = useMock;

  Future<Map<String, dynamic>> getNotifications() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockDataService().getMockNotifications();
    }
    try {
      final data = await _client.get(ApiConstants.notifications);
      final notifications = (data['notifications'] as List? ?? [])
          .map((e) => NotificationModel.fromJson(e))
          .toList();
      return {
        'notifications': notifications,
        'unreadCount': data['unreadCount'] ?? 0,
      };
    } catch (_) {
      return MockDataService().getMockNotifications();
    }
  }

  Future<void> markAsRead(String id) async {
    if (_useMock) return;
    try {
      await _client.patch(ApiConstants.notificationRead(id));
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    if (_useMock) return;
    try {
      await _client.post(ApiConstants.notificationsMarkAllRead);
    } catch (_) {}
  }
}
