import 'package:json_annotation/json_annotation.dart';

part 'cancelled_event_item.g.dart';

@JsonSerializable()
class CancelledEventItem {
  String? eventName;
  String? locationName;
  DateTime? eventDate;
  int? ticketsSold;
  int? refundsNeeded;
  double? totalRefundAmount;

  CancelledEventItem({
    this.eventName,
    this.locationName,
    this.eventDate,
    this.ticketsSold,
    this.refundsNeeded,
    this.totalRefundAmount,
  });

  factory CancelledEventItem.fromJson(Map<String, dynamic> json) =>
      _$CancelledEventItemFromJson(json);

  Map<String, dynamic> toJson() => _$CancelledEventItemToJson(this);
}
