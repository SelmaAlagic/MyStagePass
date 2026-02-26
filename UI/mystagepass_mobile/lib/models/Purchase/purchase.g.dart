// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Purchase _$PurchaseFromJson(Map<String, dynamic> json) => Purchase(
  purchaseID: (json['purchaseID'] as num?)?.toInt(),
  purchaseDate: json['purchaseDate'] == null
      ? null
      : DateTime.parse(json['purchaseDate'] as String),
  customerID: (json['customerID'] as num?)?.toInt(),
  tickets: (json['tickets'] as List<dynamic>?)
      ?.map((e) => Ticket.fromJson(e as Map<String, dynamic>))
      .toList(),
  isDeleted: json['isDeleted'] as bool?,
  total: (json['total'] as num?)?.toInt(),
);

Map<String, dynamic> _$PurchaseToJson(Purchase instance) => <String, dynamic>{
  'purchaseID': instance.purchaseID,
  'purchaseDate': instance.purchaseDate?.toIso8601String(),
  'customerID': instance.customerID,
  'tickets': instance.tickets,
  'isDeleted': instance.isDeleted,
  'total': instance.total,
};
