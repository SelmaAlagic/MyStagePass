// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genre.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Genre _$GenreFromJson(Map<String, dynamic> json) => Genre(
  genreID: (json['genreID'] as num).toInt(),
  name: json['name'] as String?,
);

Map<String, dynamic> _$GenreToJson(Genre instance) => <String, dynamic>{
  'genreID': instance.genreID,
  'name': instance.name,
};
