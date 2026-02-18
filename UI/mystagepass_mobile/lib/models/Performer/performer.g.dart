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
);

Map<String, dynamic> _$PerformerToJson(Performer instance) => <String, dynamic>{
  'performerID': instance.performerID,
  'isApproved': instance.isApproved,
  'user': instance.user,
};
