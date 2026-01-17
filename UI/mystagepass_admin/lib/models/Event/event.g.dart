// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  eventId: (json['eventId'] as num?)?.toInt(),
  eventName: json['eventName'] as String?,
  ticketsSold: (json['ticketsSold'] as num?)?.toInt(),
  locationName: json['locationName'] as String?,
  eventDate: json['eventDate'] == null
      ? null
      : DateTime.parse(json['eventDate'] as String),
  timeStatus: json['timeStatus'] as String?,
  performer: json['performer'] == null
      ? null
      : Performer.fromJson(json['performer'] as Map<String, dynamic>),
  location: json['location'] == null
      ? null
      : Location.fromJson(json['location'] as Map<String, dynamic>),
  status: json['status'] == null
      ? null
      : Status.fromJson(json['status'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'eventId': instance.eventId,
  'eventName': instance.eventName,
  'ticketsSold': instance.ticketsSold,
  'locationName': instance.locationName,
  'eventDate': instance.eventDate?.toIso8601String(),
  'timeStatus': instance.timeStatus,
  'performer': instance.performer,
  'location': instance.location,
  'status': instance.status,
};
