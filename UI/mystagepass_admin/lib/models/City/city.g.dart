// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

City _$CityFromJson(Map<String, dynamic> json) => City(
  cityId: (json['cityID'] as num?)?.toInt(),
  name: json['name'] as String?,
  isActive: json['isActive'] as bool?,
  countryId: (json['countryID'] as num?)?.toInt(),
  locations: (json['locations'] as List<dynamic>?)
      ?.where((e) => e != null)
      .map((e) => Location.fromJson(e as Map<String, dynamic>))
      .toList(),
  country: json['country'] == null
      ? null
      : Country.fromJson(json['country'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
  'cityID': instance.cityId,
  'name': instance.name,
  'isActive': instance.isActive,
  'countryID': instance.countryId,
  'locations': instance.locations,
  'country': instance.country,
};
