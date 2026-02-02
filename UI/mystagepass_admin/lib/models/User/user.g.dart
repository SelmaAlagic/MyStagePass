// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  userId: (json['userID'] as num?)?.toInt(),
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
  role: json['role'] as String?,
  username: json['username'] as String?,
  isActive: json['isActive'] as bool?,
  phoneNumber: json['phoneNumber'] as String?,
  image: json['image'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'userID': instance.userId,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'role': instance.role,
  'username': instance.username,
  'isActive': instance.isActive,
  'phoneNumber': instance.phoneNumber,
  'image': instance.image,
};
