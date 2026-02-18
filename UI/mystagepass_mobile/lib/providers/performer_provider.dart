import 'dart:convert';
import 'package:http/http.dart' as http;
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
}
