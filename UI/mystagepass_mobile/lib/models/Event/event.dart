import 'package:json_annotation/json_annotation.dart';
import 'package:mystagepass_mobile/models/Status/status.dart';
import '../Performer/performer.dart';
import '../Location/location.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
  int? eventID;
  String? eventName;
  int? ticketsSold;
  int? totalTickets;
  DateTime? eventDate;
  String? timeStatus;
  int? regularPrice;
  int? vipPrice;
  int? premiumPrice;
  double? ratingAverage;
  int? ratingCount;
  int? userRating;
  String? description;

  Performer? performer;
  Location? location;
  Status? status;

  Event({
    this.eventID,
    this.eventName,
    this.ticketsSold,
    this.totalTickets,
    this.eventDate,
    this.timeStatus,
    this.regularPrice,
    this.vipPrice,
    this.premiumPrice,
    this.performer,
    this.location,
    this.ratingAverage,
    this.ratingCount,
    this.userRating,
    this.status,
    this.description,
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);
}
