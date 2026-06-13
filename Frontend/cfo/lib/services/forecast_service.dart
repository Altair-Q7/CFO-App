import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/forecast_result.dart';

class ForecastService {
  final ApiClient _client;
  ForecastService(this._client);

  Future<ForecastResult> getProjection({
    int months = 12,
    double revenueGrowth = 5,
    double expenseGrowth = 3,
    double hiringCost = 0,
  }) async {
    final data = await _client.post(ApiConstants.forecastingProject, body: {
      'months': months,
      'revenueGrowth': revenueGrowth,
      'expenseGrowth': expenseGrowth,
      'hiringCost': hiringCost,
    });
    return ForecastResult.fromJson(data);
  }
}