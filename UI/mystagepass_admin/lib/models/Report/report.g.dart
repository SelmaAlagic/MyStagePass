// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) => Report(
  totalTicketsSold: (json['totalTicketsSold'] as num?)?.toInt(),
  totalRevenue: (json['totalRevenue'] as num?)?.toDouble(),
  topPerformer: json['topPerformer'] as String?,
  topLocation: json['topLocation'] as String?,
  performerSales: (json['performerSales'] as List<dynamic>?)
      ?.map((e) => Chart.fromJson(e as Map<String, dynamic>))
      .toList(),
  locationSales: (json['locationSales'] as List<dynamic>?)
      ?.map((e) => Chart.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
  'totalTicketsSold': instance.totalTicketsSold,
  'totalRevenue': instance.totalRevenue,
  'topPerformer': instance.topPerformer,
  'topLocation': instance.topLocation,
  'performerSales': instance.performerSales,
  'locationSales': instance.locationSales,
};
