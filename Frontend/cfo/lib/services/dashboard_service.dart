import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/dashboard_metrics.dart';
import '../models/financial_data.dart';
import '../models/transaction_model.dart';
import '../models/notification_model.dart';

class DashboardService {
  final ApiClient _client;
  DashboardService(this._client);

  Future<DashboardMetrics> getMetrics() async {
    final data = await _client.get(ApiConstants.dashboardMetrics);
    return DashboardMetrics.fromJson(data);
  }

  Future<List<FinancialData>> getTrends() async {
    final data = await _client.get(ApiConstants.dashboardTrends);
    final trends = data['trends'] as List? ?? [];
    return trends.map((e) => FinancialData.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getActivity() async {
    final data = await _client.get(ApiConstants.dashboardActivity);
    final transactions = (data['transactions'] as List? ?? []).map((e) => TransactionModel.fromJson(e)).toList();
    final notifications = (data['notifications'] as List? ?? []).map((e) => NotificationModel.fromJson(e)).toList();
    return {'transactions': transactions, 'notifications': notifications};
  }
}