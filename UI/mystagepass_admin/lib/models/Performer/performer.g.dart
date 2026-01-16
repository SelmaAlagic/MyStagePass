// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Performer _$PerformerFromJson(Map<String, dynamic> json) => Performer(
  performerId: (json['performerID'] as num?)?.toInt(),
  artistName: json['artistName'] as String?,
  bio: json['bio'] as String?,
  isApproved: json['isApproved'] as bool?,
  averageRating: (json['averageRating'] as num?)?.toDouble(),
  genres: (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PerformerToJson(Performer instance) => <String, dynamic>{
  'performerID': instance.performerId,
  'artistName': instance.artistName,
  'bio': instance.bio,
  'isApproved': instance.isApproved,
  'averageRating': instance.averageRating,
  'genres': instance.genres,
  'user': instance.user,
};
