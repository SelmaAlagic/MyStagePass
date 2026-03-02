// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Status _$StatusFromJson(Map<String, dynamic> json) => Status(
  statusId: (json['statusId'] as num?)?.toInt(),
  statusName: json['statusName'] as String?,
);

Map<String, dynamic> _$StatusToJson(Status instance) => <String, dynamic>{
  'statusId': instance.statusId,
  'statusName': instance.statusName,
};
