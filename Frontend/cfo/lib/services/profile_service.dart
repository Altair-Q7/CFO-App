import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';

class ProfileService {
  final ApiClient _client;
  ProfileService(this._client);

  Future<Map<String, dynamic>> getProfile() async {
    final data = await _client.get(ApiConstants.profile);
    return data;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? companyName,
    String? industry,
    double? monthlyRevenue,
    double? monthlyExpenses,
    int? employees,
  }) async {
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