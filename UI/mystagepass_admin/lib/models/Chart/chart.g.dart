// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chart _$ChartFromJson(Map<String, dynamic> json) => Chart(
  name: json['name'] as String?,
  value: (json['value'] as num?)?.toInt(),
);

Map<String, dynamic> _$ChartToJson(Chart instance) => <String, dynamic>{
  'name': instance.name,
  'value': instance.value,
};
