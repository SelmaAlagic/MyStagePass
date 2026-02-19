import 'package:json_annotation/json_annotation.dart';
import '../Performer/performer.dart';
import '../Location/location.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  int? eventID;
  String? eventName;
  int? ticketsSold;
  DateTime? eventDate;
  String? timeStatus;
  int? regularPrice;
  int? vipPrice;
  int? premiumPrice;

  Performer? performer;
  Location? location;

  Event({
    this.eventID,
    this.eventName,
    this.ticketsSold,
    this.eventDate,
    this.timeStatus,
    this.regularPrice,
    this.vipPrice,
    this.premiumPrice,
    this.performer,
    this.location,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);
}
