import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/advisor_model.dart';

class MarketplaceService {
  final ApiClient _client;
  MarketplaceService(this._client);

  Future<List<AdvisorModel>> getAdvisors({String? industry, double? rating, String? region, String? search}) async {
    final data = await _client.get(ApiConstants.marketplaceAdvisors, auth: false);
    final advisors = data['advisors'] as List? ?? [];
    return advisors.map((e) => AdvisorModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getAdvisorDetail(String id) async {
    final data = await _client.get(ApiConstants.advisorById(id), auth: false);
    final advisor = AdvisorModel.fromJson(data['advisor']);
    final reviews = (data['reviews'] as List? ?? []).map((e) => ReviewModel.fromJson(e)).toList();
    return {'advisor': advisor, 'reviews': reviews};
  }

  Future<Map<String, dynamic>> bookAdvisor(String advisorId, String date) async {
    final data = await _client.post(ApiConstants.marketplaceBook, body: {
      'advisorId': advisorId,
      'date': date,
    });
    return data;
  }
}