// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancelled_event_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelledEventItem _$CancelledEventItemFromJson(Map<String, dynamic> json) =>
    CancelledEventItem(
      eventName: json['eventName'] as String?,
      locationName: json['locationName'] as String?,
      eventDate: json['eventDate'] == null
          ? null
          : DateTime.parse(json['eventDate'] as String),
      ticketsSold: (json['ticketsSold'] as num?)?.toInt(),
      refundsNeeded: (json['refundsNeeded'] as num?)?.toInt(),
      totalRefundAmount: (json['totalRefundAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CancelledEventItemToJson(CancelledEventItem instance) =>
    <String, dynamic>{
      'eventName': instance.eventName,
      'locationName': instance.locationName,
      'eventDate': instance.eventDate?.toIso8601String(),
      'ticketsSold': instance.ticketsSold,
      'refundsNeeded': instance.refundsNeeded,
      'totalRefundAmount': instance.totalRefundAmount,
    };
