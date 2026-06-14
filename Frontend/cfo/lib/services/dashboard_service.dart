import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/dashboard_metrics.dart';
import '../models/financial_data.dart';
import '../models/transaction_model.dart';
import '../models/notification_model.dart';
import '../services/mock_data_service.dart';

class DashboardService {
  final ApiClient _client;
  final bool _useMock;

  DashboardService(this._client, {bool useMock = true}) : _useMock = useMock;

  Future<DashboardMetrics> getMetrics() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockDataService().getMockMetrics();
    }
    try {
      final data = await _client.get(ApiConstants.dashboardMetrics);
      return DashboardMetrics.fromJson(data);
    } catch (_) {
      return MockDataService().getMockMetrics();
    }
  }

  Future<List<FinancialData>> getTrends() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockDataService().getMockTrends();
    }
    try {
      final data = await _client.get(ApiConstants.dashboardTrends);
      final trends = data['trends'] as List? ?? [];
      return trends.map((e) => FinancialData.fromJson(e)).toList();
    } catch (_) {
      return MockDataService().getMockTrends();
    }
  }

  Future<Map<String, dynamic>> getActivity() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockDataService().getMockActivity();
    }
    try {
      final data = await _client.get(ApiConstants.dashboardActivity);
      final transactions = (data['transactions'] as List? ?? [])
          .map((e) => TransactionModel.fromJson(e))
          .toList();
      final notifications = (data['notifications'] as List? ?? [])
          .map((e) => NotificationModel.fromJson(e))
          .toList();
      return {'transactions': transactions, 'notifications': notifications};
    } catch (_) {
      return MockDataService().getMockActivity();
    }
  }
}
