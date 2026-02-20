// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Performer _$PerformerFromJson(Map<String, dynamic> json) => Performer(
  (json['performerID'] as num?)?.toInt(),
  json['isApproved'] as bool?,
  json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  json['artistName'] as String?,
  json['bio'] as String?,
  (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$PerformerToJson(Performer instance) => <String, dynamic>{
  'performerID': instance.performerID,
  'isApproved': instance.isApproved,
  'artistName': instance.artistName,
  'bio': instance.bio,
  'genres': instance.genres,
  'user': instance.user,
};
