import 'package:json_annotation/json_annotation.dart';

part 'payment_intent_response.g.dart';

@JsonSerializable()
class PaymentIntentResponse {
  String? paymentIntentId;
  String? clientSecret;
  int? amountInEur;

  PaymentIntentResponse({
    this.paymentIntentId,
    this.clientSecret,
    this.amountInEur,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentIntentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentIntentResponseToJson(this);
}
