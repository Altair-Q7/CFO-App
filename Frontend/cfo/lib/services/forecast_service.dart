import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/forecast_result.dart';
import '../services/mock_data_service.dart';

class ForecastService {
  final ApiClient _client;
  final bool _useMock;

  ForecastService(this._client, {bool useMock = true}) : _useMock = useMock;

  Future<ForecastResult> getProjection({
    int months = 12,
    double revenueGrowth = 5,
    double expenseGrowth = 3,
    double hiringCost = 0,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockDataService().getMockForecast(
        months: months,
        revenueGrowth: revenueGrowth,
        expenseGrowth: expenseGrowth,
      );
    }
    try {
      final data = await _client.post(ApiConstants.forecastingProject, body: {
        'months': months,
        'revenueGrowth': revenueGrowth,
        'expenseGrowth': expenseGrowth,
        'hiringCost': hiringCost,
      });
      return ForecastResult.fromJson(data);
    } catch (_) {
      return MockDataService().getMockForecast(
        months: months,
        revenueGrowth: revenueGrowth,
        expenseGrowth: expenseGrowth,
      );
    }
  }
}
