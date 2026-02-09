import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/Report/report.dart';
import 'base_provider.dart';

class ReportProvider extends BaseProvider<Report> {
  static const String _endpoint = "api/Reports";

  Report? _reportData;
  bool _isLoading = false;
  String? _error;

  Report? get reportData => _reportData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ReportProvider() : super(_endpoint);

  @override
  Report fromJson(data) => Report.fromJson(data);

  Future<void> fetchMonthlyReport(int month, int year) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(
        '${getBaseUrl()}$_endpoint?month=$month&year=$year',
      );
      final headers = await createHeaders();
      final response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        final jsonData = jsonDecode(response.body);
        _reportData = Report.fromJson(jsonData);
      } else {
        _error = "Greška pri dohvaćanju izvještaja";
      }
    } catch (e) {
      _error = "Greška: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<int>?> downloadPdfBytes(int month, int year) async {
    try {
      final uri = Uri.parse(
        '${getBaseUrl()}$_endpoint/export-pdf?month=$month&year=$year',
      );
      final headers = await createHeaders();
      final response = await http.get(uri, headers: headers);

      if (isValidResponse(response)) {
        return response.bodyBytes;
      } else {
        _error = "Greška pri preuzimanju PDF-a (${response.statusCode})";
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = "Greška: $e";
      notifyListeners();
      return null;
    }
  }
}
