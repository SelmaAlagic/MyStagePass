import 'package:http/http.dart' as http;
import '../models/Event/event.dart';
import 'base_provider.dart';

class EventProvider extends BaseProvider<Event> {
  static const String _eventEndpoint = "api/Event/admin/all";

  EventProvider() : super(_eventEndpoint);

  @override
  Event fromJson(data) {
    return Event.fromJson(data);
  }

  Future<void> updateStatus(int id, String status, {String? reason}) async {
    var urlStr = '${getBaseUrl()}api/Event/$id/status?newStatus=$status';
    if (reason != null) {
      urlStr += '&reason=${Uri.encodeComponent(reason)}';
    }
    final url = Uri.parse(urlStr);

    final headers = await createHeaders();
    final response = await http.put(url, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception(response.body);
    }
  }

  Future<void> cancelEvent(int id, String reason) async {
    final url = Uri.parse(
      '${getBaseUrl()}api/Event/$id/cancel?reason=${Uri.encodeComponent(reason)}',
    );

    final headers = await createHeaders();
    final response = await http.put(url, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception(response.body);
    }
  }
}
