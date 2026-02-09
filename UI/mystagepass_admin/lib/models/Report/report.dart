import 'package:json_annotation/json_annotation.dart';
import '../Chart/chart.dart';

part 'report.g.dart';

@JsonSerializable()
class Report {
  int? totalTicketsSold;
  double? totalRevenue;
  String? topPerformer;
  String? topLocation;
  List<Chart>? performerSales;
  List<Chart>? locationSales;

  Report({
    this.totalTicketsSold,
    this.totalRevenue,
    this.topPerformer,
    this.topLocation,
    this.performerSales,
    this.locationSales,
  });

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

  Map<String, dynamic> toJson() => _$ReportToJson(this);
}
