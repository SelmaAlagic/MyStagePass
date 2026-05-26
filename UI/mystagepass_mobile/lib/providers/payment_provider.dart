import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_provider.dart';
import '../models/payment/payment_intent_response.dart';

class PaymentProvider extends BaseProvider {
  PaymentProvider() : super("api/Payment");

  Future<PaymentIntentResponse> createPaymentIntent({
    required int eventId,
    required int numberOfTickets,
    required int ticketType,
  }) async {
    var url = "${getBaseUrl()}api/Payment/create-payment-intent";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var body = jsonEncode({
      'eventId': eventId,
      'numberOfTickets': numberOfTickets,
      'ticketType': ticketType,
    });

    var response = await http.post(uri, headers: headers, body: body);

    if (isValidResponse(response)) {
      final data = jsonDecode(response.body);
      return PaymentIntentResponse.fromJson(data);
    } else {
      throw Exception("Failed to create payment intent");
    }
  }

  Future<void> verifyAndPurchase(String paymentIntentId) async {
    var url = "${getBaseUrl()}api/Payment/verify-and-purchase";
    var uri = Uri.parse(url);
    var headers = await createHeaders();

    var body = jsonEncode({'paymentIntentId': paymentIntentId});

    var response = await http.post(uri, headers: headers, body: body);

    if (!isValidResponse(response)) {
      final errorBody = jsonDecode(response.body);
      final errorMsg = errorBody['errors']?['error']?[0] ?? response.body;
      throw Exception(errorMsg);
    }
  }
}
