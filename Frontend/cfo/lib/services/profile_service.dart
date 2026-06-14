import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../services/mock_data_service.dart';

class ProfileService {
  final ApiClient _client;
  final bool _useMock;

  ProfileService(this._client, {bool useMock = true}) : _useMock = useMock;

  Future<Map<String, dynamic>> getProfile() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockDataService().getMockProfile();
    }
    try {
      final data = await _client.get(ApiConstants.profile);
      return data;
    } catch (_) {
      return MockDataService().getMockProfile();
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? companyName,
    String? industry,
    double? monthlyRevenue,
    double? monthlyExpenses,
    int? employees,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {'success': true};
    }
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (companyName != null) body['companyName'] = companyName;
    if (industry != null) body['industry'] = industry;
    if (monthlyRevenue != null) body['monthlyRevenue'] = monthlyRevenue;
    if (monthlyExpenses != null) body['monthlyExpenses'] = monthlyExpenses;
    if (employees != null) body['employees'] = employees;
    return await _client.put(ApiConstants.profile, body: body);
  }
}
