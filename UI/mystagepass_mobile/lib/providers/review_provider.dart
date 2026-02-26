import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_provider.dart';

class ReviewProvider extends BaseProvider<dynamic> {
  ReviewProvider() : super("api/Review");

  Future<void> submitReview({required int eventId, required int rating}) async {
    var url = "${getBaseUrl()}api/Review/submit";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var body = jsonEncode({"eventID": eventId, "ratingValue": rating});

    var response = await http.post(uri, headers: headers, body: body);

    if (!isValidResponse(response)) {
      throw Exception("Failed to submit review");
    }
  }
}
