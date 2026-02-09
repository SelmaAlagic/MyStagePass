// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  locationId: (json['locationID'] as num?)?.toInt(),
  locationName: json['locationName'] as String?,
  capacity: (json['capacity'] as num?)?.toInt(),
  address: json['address'] as String?,
  cityId: (json['cityID'] as num?)?.toInt(),
  city: json['city'] == null
      ? null
      : City.fromJson(json['city'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'locationID': instance.locationId,
  'locationName': instance.locationName,
  'capacity': instance.capacity,
  'address': instance.address,
  'cityID': instance.cityId,
  'city': instance.city,
};
