// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
  (json['customerID'] as num?)?.toInt(),
  json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
  'customerID': instance.customerID,
  'user': instance.user,
};
