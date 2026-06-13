import 'dart:typed_data';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/report_data.dart';

class ReportsService {
  final ApiClient _client;
  ReportsService(this._client);

  Future<ReportData> getReport(String type) async {
    final data = await _client.get(ApiConstants.reportById(type));
    return ReportData.fromJson(data);
  }

  Future<Uint8List> getReportPdf(String type) async {
    final response = await _client.getRaw(ApiConstants.reportPdf(type));
    return response.bodyBytes;
  }
}