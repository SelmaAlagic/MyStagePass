// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket(
  ticketID: (json['ticketID'] as num?)?.toInt(),
  price: (json['price'] as num?)?.toInt(),
  eventID: (json['eventID'] as num?)?.toInt(),
  purchaseID: (json['purchaseID'] as num?)?.toInt(),
  ticketType: (json['ticketType'] as num?)?.toInt(),
  qrCodeData: json['qrCodeData'] as String?,
  isDeleted: json['isDeleted'] as bool?,
  event: json['event'] == null
      ? null
      : Event.fromJson(json['event'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
  'ticketID': instance.ticketID,
  'price': instance.price,
  'eventID': instance.eventID,
  'purchaseID': instance.purchaseID,
  'ticketType': instance.ticketType,
  'qrCodeData': instance.qrCodeData,
  'isDeleted': instance.isDeleted,
  'event': instance.event,
};
