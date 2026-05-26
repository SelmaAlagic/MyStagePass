// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Country _$CountryFromJson(Map<String, dynamic> json) => Country(
  countryId: (json['countryID'] as num?)?.toInt(),
  name: json['name'] as String?,
  isActive: json['isActive'] as bool?,
  cities: (json['cities'] as List<dynamic>?)
      ?.where((e) => e != null)
      .map((e) => City.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
  'countryID': instance.countryId,
  'name': instance.name,
  'isActive': instance.isActive,
  'cities': instance.cities,
};
