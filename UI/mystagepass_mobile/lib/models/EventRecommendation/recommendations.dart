import 'package:json_annotation/json_annotation.dart';

part 'recommendations.g.dart';

@JsonSerializable()
class Recommendations {
  String? eventName;
  String? performerName;
  String? eventDate;
  String? cityName;
  Map<String, int>? ticketPrices;
  double? similarityScore;

  Recommendations({
    this.eventName,
    this.performerName,
    this.eventDate,
    this.cityName,
    this.ticketPrices,
    this.similarityScore,
  });

  factory Recommendations.fromJson(Map<String, dynamic> json) =>
      _$RecommendationsFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationsToJson(this);
}
