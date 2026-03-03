import 'package:json_annotation/json_annotation.dart';

part 'statistics.g.dart';

@JsonSerializable()
class Statistics {
  int? totalTicketsSold;
  double? totalRevenue;
  double? regularRevenue;
  double? vipRevenue;
  double? premiumRevenue;
  int? regularTicketsSold;
  int? vipTicketsSold;
  int? premiumTicketsSold;

  Statistics({
    this.totalTicketsSold,
    this.totalRevenue,
    this.regularRevenue,
    this.vipRevenue,
    this.premiumRevenue,
    this.regularTicketsSold,
    this.vipTicketsSold,
    this.premiumTicketsSold,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) =>
      _$StatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$StatisticsToJson(this);
}
