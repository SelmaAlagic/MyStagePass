// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recommendations _$RecommendationsFromJson(Map<String, dynamic> json) =>
    Recommendations(
      eventName: json['eventName'] as String?,
      performerName: json['performerName'] as String?,
      eventDate: json['eventDate'] as String?,
      cityName: json['cityName'] as String?,
      ticketPrices: (json['ticketPrices'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      similarityScore: (json['similarityScore'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$RecommendationsToJson(Recommendations instance) =>
    <String, dynamic>{
      'eventName': instance.eventName,
      'performerName': instance.performerName,
      'eventDate': instance.eventDate,
      'cityName': instance.cityName,
      'ticketPrices': instance.ticketPrices,
      'similarityScore': instance.similarityScore,
    };
