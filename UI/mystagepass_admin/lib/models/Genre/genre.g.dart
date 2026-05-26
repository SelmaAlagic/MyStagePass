// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genre.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Genre _$GenreFromJson(Map<String, dynamic> json) => Genre(
  genreId: (json['genreID'] as num?)?.toInt(),
  name: json['name'] as String?,
  performers: (json['performers'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$GenreToJson(Genre instance) => <String, dynamic>{
  'genreID': instance.genreId,
  'name': instance.name,
  'performers': instance.performers,
};
