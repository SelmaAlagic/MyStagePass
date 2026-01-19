// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  notificationID: (json['notificationID'] as num?)?.toInt(),
  userID: (json['userID'] as num?)?.toInt(),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  message: json['message'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  isRead: json['isRead'] as bool?,
  isDeleted: json['isDeleted'] as bool?,
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'notificationID': instance.notificationID,
      'userID': instance.userID,
      'user': instance.user,
      'message': instance.message,
      'createdAt': instance.createdAt?.toIso8601String(),
      'isRead': instance.isRead,
      'isDeleted': instance.isDeleted,
    };
