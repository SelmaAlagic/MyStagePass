// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancelled_events_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelledEventsReport _$CancelledEventsReportFromJson(
  Map<String, dynamic> json,
) => CancelledEventsReport(
  cityName: json['cityName'] as String?,
  totalCancelledEvents: (json['totalCancelledEvents'] as num?)?.toInt(),
  totalTicketsSold: (json['totalTicketsSold'] as num?)?.toInt(),
  totalRefundsNeeded: (json['totalRefundsNeeded'] as num?)?.toInt(),
  events: (json['events'] as List<dynamic>?)
      ?.map((e) => CancelledEventItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CancelledEventsReportToJson(
  CancelledEventsReport instance,
) => <String, dynamic>{
  'cityName': instance.cityName,
  'totalCancelledEvents': instance.totalCancelledEvents,
  'totalTicketsSold': instance.totalTicketsSold,
  'totalRefundsNeeded': instance.totalRefundsNeeded,
  'events': instance.events,
};
