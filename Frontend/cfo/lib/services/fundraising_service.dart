import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/report_data.dart';
import '../services/mock_data_service.dart';

class FundraisingService {
  final ApiClient _client;
  final bool _useMock;

  FundraisingService(this._client, {bool useMock = true}) : _useMock = useMock;

  Future<FundraisingReadiness> getReadiness() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      // Parse the mock data into the model
      final mockData = MockDataService().getMockFundraisingReadiness();
      return FundraisingReadiness.fromJson(mockData);
    }
    try {
      final data = await _client.get(ApiConstants.fundraisingReadiness);
      return FundraisingReadiness.fromJson(data);
    } catch (_) {
      final mockData = MockDataService().getMockFundraisingReadiness();
      return FundraisingReadiness.fromJson(mockData);
    }
  }

  Future<List<DataRoomFile>> getDataRoom() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final mockFiles = MockDataService().getMockDataRoomFiles();
      return mockFiles.map((e) => DataRoomFile.fromJson(e)).toList();
    }
    try {
      final data = await _client.get(ApiConstants.fundraisingDataRoom);
      final files = data['files'] as List? ?? [];
      return files.map((e) => DataRoomFile.fromJson(e)).toList();
    } catch (_) {
      final mockFiles = MockDataService().getMockDataRoomFiles();
      return mockFiles.map((e) => DataRoomFile.fromJson(e)).toList();
    }
  }
}
