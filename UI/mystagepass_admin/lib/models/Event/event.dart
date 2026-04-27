import 'package:json_annotation/json_annotation.dart';
import '../Performer/performer.dart';
import '../Location/location.dart';
import '../Status/status.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  @JsonKey(name: 'eventID')
  int? eventId;
  String? eventName;
  int? ticketsSold;
  String? locationName;
  DateTime? eventDate;
  String? timeStatus;
  int? regularPrice;
  int? vipPrice;
  int? premiumPrice;
  DateTime? createdAt;
  @JsonKey(name: 'isCancelled')
  bool? isCancelled;
  Performer? performer;
  Location? location;
  Status? status;

  Event({
    this.eventId,
    this.eventName,
    this.ticketsSold,
    this.locationName,
    this.eventDate,
    this.timeStatus,
    this.regularPrice,
    this.vipPrice,
    this.premiumPrice,
    this.isCancelled,
    this.performer,
    this.location,
    this.status,
    this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);
}
