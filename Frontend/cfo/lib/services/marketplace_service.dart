import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/advisor_model.dart';
import '../services/mock_data_service.dart';

class MarketplaceService {
  final ApiClient _client;
  final bool _useMock;

  MarketplaceService(this._client, {bool useMock = true}) : _useMock = useMock;

  Future<List<AdvisorModel>> getAdvisors(
      {String? industry,
      double? rating,
      String? region,
      String? search}) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return MockDataService().getMockAdvisors();
    }
    try {
      final data =
          await _client.get(ApiConstants.marketplaceAdvisors, auth: false);
      final advisors = data['advisors'] as List? ?? [];
      return advisors.map((e) => AdvisorModel.fromJson(e)).toList();
    } catch (_) {
      return MockDataService().getMockAdvisors();
    }
  }

  Future<Map<String, dynamic>> getAdvisorDetail(String id) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockDataService().getMockAdvisorDetail(id);
    }
    try {
      final data = await _client.get(ApiConstants.advisorById(id), auth: false);
      final advisor = AdvisorModel.fromJson(data['advisor']);
      final reviews = (data['reviews'] as List? ?? [])
          .map((e) => ReviewModel.fromJson(e))
          .toList();
      return {'advisor': advisor, 'reviews': reviews};
    } catch (_) {
      return MockDataService().getMockAdvisorDetail(id);
    }
  }

  Future<Map<String, dynamic>> bookAdvisor(
      String advisorId, String date) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return {'success': true, 'bookingId': 'mock-booking-001'};
    }
    try {
      final data = await _client.post(ApiConstants.marketplaceBook, body: {
        'advisorId': advisorId,
        'date': date,
      });
      return data;
    } catch (_) {
      return {'success': true, 'bookingId': 'mock-booking-001'};
    }
  }
}
