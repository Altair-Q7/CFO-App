import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/report_data.dart';

class FundraisingService {
  final ApiClient _client;
  FundraisingService(this._client);

  Future<FundraisingReadiness> getReadiness() async {
    final data = await _client.get(ApiConstants.fundraisingReadiness);
    return FundraisingReadiness.fromJson(data);
  }

  Future<List<DataRoomFile>> getDataRoom() async {
    final data = await _client.get(ApiConstants.fundraisingDataRoom);
    final files = data['files'] as List? ?? [];
    return files.map((e) => DataRoomFile.fromJson(e)).toList();
  }
}