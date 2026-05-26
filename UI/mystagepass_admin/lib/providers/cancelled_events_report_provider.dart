import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/CancelledEventsReport/cancelled_events_report.dart';
import 'base_provider.dart';

class CancelledEventsReportProvider
    extends BaseProvider<CancelledEventsReport> {
  static const String _reportEndpoint = "api/Reports/cancelled";

  CancelledEventsReport? _reportData;
  bool _isLoadingReport = false;
  String? _error;

  CancelledEventsReportProvider() : super(_reportEndpoint);

  @override
  CancelledEventsReport fromJson(data) => CancelledEventsReport.fromJson(data);

  CancelledEventsReport? get reportData => _reportData;
  bool get isLoadingReport => _isLoadingReport;
  String? get error => _error;

  Future<void> fetchCancelledReport(int cityId) async {
    _isLoadingReport = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('${getBaseUrl()}$_reportEndpoint?cityId=$cityId');
      final headers = await createHeaders();
      final response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        final jsonData = jsonDecode(response.body);
        _reportData = CancelledEventsReport.fromJson(jsonData);
      }
    } catch (e) {
      _error = 'Greška: $e';
    } finally {
      _isLoadingReport = false;
      notifyListeners();
    }
  }

  void clearReport() {
    _reportData = null;
    _error = null;
    notifyListeners();
  }
}
