// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_intent_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentIntentResponse _$PaymentIntentResponseFromJson(
  Map<String, dynamic> json,
) => PaymentIntentResponse(
  paymentIntentId: json['paymentIntentId'] as String?,
  clientSecret: json['clientSecret'] as String?,
  amountInEur: (json['amountInEur'] as num?)?.toInt(),
);

Map<String, dynamic> _$PaymentIntentResponseToJson(
  PaymentIntentResponse instance,
) => <String, dynamic>{
  'paymentIntentId': instance.paymentIntentId,
  'clientSecret': instance.clientSecret,
  'amountInEur': instance.amountInEur,
};
