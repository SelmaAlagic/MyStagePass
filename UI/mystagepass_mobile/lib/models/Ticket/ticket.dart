import 'package:json_annotation/json_annotation.dart';
import '../Event/event.dart';

part 'ticket.g.dart';

@JsonSerializable()
class Ticket {
  int? ticketID;
  int? price;
  int? eventID;
  int? purchaseID;
  int? ticketType;
  String? qrCodeData;
  bool? isDeleted;
  Event? event;

  Ticket({
    this.ticketID,
    this.price,
    this.eventID,
    this.purchaseID,
    this.ticketType,
    this.qrCodeData,
    this.isDeleted,
    this.event,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
  Map<String, dynamic> toJson() => _$TicketToJson(this);

  String getTicketTypeDisplay() {
    switch (ticketType) {
      case 1:
        return 'Regular';
      case 2:
        return 'VIP';
      case 3:
        return 'Premium';
      default:
        return 'Unknown';
    }
  }
}
