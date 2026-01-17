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

  Future<void> updateStatus(int id, String status) async {
    final url = Uri.parse(
      '${getBaseUrl()}$_eventEndpoint/$id/status?status=$status',
    );
    final headers = await createHeaders();
    final response = await http.put(url, headers: headers);

    if (!isValidResponse(response)) {
      throw Exception("Greška pri izmjeni statusa");
    }
  }
}
