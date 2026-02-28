import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/Purchase/purchase.dart';
import '../models/Event/event.dart';
import '../models/search_result.dart';
import '../models/Meta/meta.dart';
import 'base_provider.dart';

class PurchaseProvider extends BaseProvider<Purchase> {
  PurchaseProvider() : super("api/Purchase");

  @override
  Purchase fromJson(data) {
    return Purchase.fromJson(data);
  }

  Future<SearchResult<Event>> getMyEvents({bool? isUpcoming}) async {
    var url = "${getBaseUrl()}api/Purchase/my-events?Page=0&PageSize=100";

    if (isUpcoming != null) {
      url += "&IsUpcoming=$isUpcoming";
    }

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

  Future<Purchase> buyTickets({
    required int eventId,
    required int ticketType,
    required int numberOfTickets,
  }) async {
    return await insert({
      'eventID': eventId,
      'customerID': 0,
      'numberOfTickets': numberOfTickets,
      'ticketType': ticketType,
    });
  }
}
