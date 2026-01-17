import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Performer/performer.dart';
import 'base_provider.dart';

class PerformerProvider extends BaseProvider<Performer> {
  static const String _performerEndpoint = "api/Performer";

  PerformerProvider() : super(_performerEndpoint);

  @override
  Performer fromJson(data) {
    return Performer.fromJson(data);
  }

  Future<Performer> approvePerformer(int id, bool isApproved) async {
    final url = Uri.parse(
      '${getBaseUrl()}$_performerEndpoint/$id/approve?isApproved=$isApproved',
    );
    final headers = await createHeaders();

    final response = await http.put(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception(
        'Failed to approve/reject performer: ${response.statusCode}',
      );
    }
  }
}
