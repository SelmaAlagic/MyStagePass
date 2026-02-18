import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Customer/customer.dart';
import 'base_provider.dart';

class CustomerProvider extends BaseProvider<Customer> {
  CustomerProvider() : super("api/Customer");

  @override
  Customer fromJson(data) {
    return Customer.fromJson(data);
  }

  Future<Customer?> register(dynamic request) async {
    var url = "${getBaseUrl()}api/Customer/register";
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
