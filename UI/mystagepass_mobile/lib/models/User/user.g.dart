// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  (json['userId'] as num?)?.toInt(),
  json['email'] as String?,
  json['role'] as String?,
  json['username'] as String?,
  json['firstName'] as String?,
  json['lastName'] as String?,
  json['fullName'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'userId': instance.userId,
  'email': instance.email,
  'role': instance.role,
  'username': instance.username,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'fullName': instance.fullName,
};
