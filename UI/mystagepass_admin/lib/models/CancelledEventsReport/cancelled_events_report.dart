import 'package:json_annotation/json_annotation.dart';
import '../CancelledEventItem/cancelled_event_item.dart';

part 'cancelled_events_report.g.dart';

@JsonSerializable()
class CancelledEventsReport {
  String? cityName;
  int? totalCancelledEvents;
  int? totalTicketsSold;
  int? totalRefundsNeeded;
  List<CancelledEventItem>? events;

  CancelledEventsReport({
    this.cityName,
    this.totalCancelledEvents,
    this.totalTicketsSold,
    this.totalRefundsNeeded,
    this.events,
  });

  factory CancelledEventsReport.fromJson(Map<String, dynamic> json) =>
      _$CancelledEventsReportFromJson(json);

  Map<String, dynamic> toJson() => _$CancelledEventsReportToJson(this);
}
