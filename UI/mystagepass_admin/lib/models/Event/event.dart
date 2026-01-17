import 'package:json_annotation/json_annotation.dart';
import '../Performer/performer.dart';
import '../Location/location.dart';
import '../Status/status.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  int? eventId;
  String? eventName;
  int? ticketsSold;
  String? locationName;
  DateTime? eventDate;
  String? timeStatus;

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
    this.performer,
    this.location,
    this.status,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);
}
