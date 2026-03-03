// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Statistics _$StatisticsFromJson(Map<String, dynamic> json) => Statistics(
  totalTicketsSold: (json['totalTicketsSold'] as num?)?.toInt(),
  totalRevenue: (json['totalRevenue'] as num?)?.toDouble(),
  regularRevenue: (json['regularRevenue'] as num?)?.toDouble(),
  vipRevenue: (json['vipRevenue'] as num?)?.toDouble(),
  premiumRevenue: (json['premiumRevenue'] as num?)?.toDouble(),
  regularTicketsSold: (json['regularTicketsSold'] as num?)?.toInt(),
  vipTicketsSold: (json['vipTicketsSold'] as num?)?.toInt(),
  premiumTicketsSold: (json['premiumTicketsSold'] as num?)?.toInt(),
);

Map<String, dynamic> _$StatisticsToJson(Statistics instance) =>
    <String, dynamic>{
      'totalTicketsSold': instance.totalTicketsSold,
      'totalRevenue': instance.totalRevenue,
      'regularRevenue': instance.regularRevenue,
      'vipRevenue': instance.vipRevenue,
      'premiumRevenue': instance.premiumRevenue,
      'regularTicketsSold': instance.regularTicketsSold,
      'vipTicketsSold': instance.vipTicketsSold,
      'premiumTicketsSold': instance.premiumTicketsSold,
    };
