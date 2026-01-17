// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

City _$CityFromJson(Map<String, dynamic> json) => City(
  cityId: (json['cityId'] as num?)?.toInt(),
  name: json['name'] as String?,
);

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
  'cityId': instance.cityId,
  'name': instance.name,
};
