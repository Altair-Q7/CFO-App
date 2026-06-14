import 'dart:typed_data';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/report_data.dart';
import '../services/mock_data_service.dart';

class ReportsService {
  final ApiClient _client;
  final bool _useMock;

  ReportsService(this._client, {bool useMock = true}) : _useMock = useMock;

  Future<ReportData> getReport(String type) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockDataService().getMockReport(type);
    }
    try {
      final data = await _client.get(ApiConstants.reportById(type));
      return ReportData.fromJson(data);
    } catch (_) {
      return MockDataService().getMockReport(type);
    }
  }

  Future<Uint8List> getReportPdf(String type) async {
    if (_useMock) {
      throw UnsupportedError('PDF generation not available in mock mode');
    }
    try {
      final response = await _client.getRaw(ApiConstants.reportPdf(type));
      return response.bodyBytes;
    } catch (_) {
      throw UnsupportedError('PDF generation not available in mock mode');
    }
  }
}
