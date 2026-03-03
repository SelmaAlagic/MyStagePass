import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mystagepass_mobile/models/Event/event.dart';
import 'package:mystagepass_mobile/models/Meta/meta.dart';
import 'package:mystagepass_mobile/models/PerformerStatistics/statistics.dart';
import 'package:mystagepass_mobile/models/search_result.dart';
import '../models/Performer/performer.dart';
import 'base_provider.dart';

class PerformerProvider extends BaseProvider<Performer> {
  PerformerProvider() : super("api/Performer");

  @override
  Performer fromJson(data) {
    return Performer.fromJson(data);
  }

  Future<Performer?> register(dynamic request) async {
    var url = "${getBaseUrl()}api/Performer/register";
    var uri = Uri.parse(url);

    var response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request),
    );

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      return null;
    }
  }

  Future<SearchResult<Event>> getMyEvents() async {
    var url = "${getBaseUrl()}api/Event/my-events?Page=0&PageSize=100";
    var uri = Uri.parse(url);
    var headers = await createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);

      SearchResult<Event> resultObj = SearchResult<Event>();
      resultObj.meta = Meta.fromJson(data['meta']);
      resultObj.result = (data['result'] as List)
          .map((x) => Event.fromJson(x))
          .toList();

      return resultObj;
    } else {
      throw Exception("Failed to load events");
    }
  }

  Future<Statistics> getMyStatistics({
    int? month,
    int? year,
    int? eventId,
  }) async {
    var url = "${getBaseUrl()}api/Performer/my-statistics";
    final params = <String, String>{};
    if (month != null) params['month'] = month.toString();
    if (year != null) params['year'] = year.toString();
    if (eventId != null) params['eventId'] = eventId.toString();
    if (params.isNotEmpty) url += '?${Uri(queryParameters: params).query}';

    var uri = Uri.parse(url);
    var headers = await createHeaders();
    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      return Statistics.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load statistics");
    }
  }
}
