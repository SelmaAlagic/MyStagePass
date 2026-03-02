import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/EventRecommendation/recommendations.dart';
import 'base_provider.dart';

class RecommendationProvider extends BaseProvider<Recommendations> {
  RecommendationProvider() : super("api/Recommendation");

  @override
  Recommendations fromJson(data) {
    return Recommendations.fromJson(data);
  }

  Future<List<Recommendations>> getRecommendations({int topN = 10}) async {
    var url = "${getBaseUrl()}api/Recommendation?topN=$topN";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Recommendations.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load recommendations");
    }
  }
}
