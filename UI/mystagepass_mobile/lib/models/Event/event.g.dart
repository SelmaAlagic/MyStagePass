// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  eventID: (json['eventID'] as num?)?.toInt(),
  eventName: json['eventName'] as String?,
  ticketsSold: (json['ticketsSold'] as num?)?.toInt(),
  totalTickets: (json['totalTickets'] as num?)?.toInt(),
  eventDate: json['eventDate'] == null
      ? null
      : DateTime.parse(json['eventDate'] as String),
  timeStatus: json['timeStatus'] as String?,
  regularPrice: (json['regularPrice'] as num?)?.toInt(),
  vipPrice: (json['vipPrice'] as num?)?.toInt(),
  premiumPrice: (json['premiumPrice'] as num?)?.toInt(),
  performer: json['performer'] == null
      ? null
      : Performer.fromJson(json['performer'] as Map<String, dynamic>),
  location: json['location'] == null
      ? null
      : Location.fromJson(json['location'] as Map<String, dynamic>),
  ratingAverage: (json['ratingAverage'] as num?)?.toDouble(),
  ratingCount: (json['ratingCount'] as num?)?.toInt(),
  userRating: (json['userRating'] as num?)?.toInt(),
  status: json['status'] == null
      ? null
      : Status.fromJson(json['status'] as Map<String, dynamic>),
  description: json['description'] as String?,
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'eventID': instance.eventID,
  'eventName': instance.eventName,
  'ticketsSold': instance.ticketsSold,
  'totalTickets': instance.totalTickets,
  'eventDate': instance.eventDate?.toIso8601String(),
  'timeStatus': instance.timeStatus,
  'regularPrice': instance.regularPrice,
  'vipPrice': instance.vipPrice,
  'premiumPrice': instance.premiumPrice,
  'ratingAverage': instance.ratingAverage,
  'ratingCount': instance.ratingCount,
  'userRating': instance.userRating,
  'description': instance.description,
  'performer': instance.performer,
  'location': instance.location,
  'status': instance.status,
};
