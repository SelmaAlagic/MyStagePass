// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Favorites _$FavoritesFromJson(Map<String, dynamic> json) => Favorites(
  (json['customerFavoriteEventID'] as num?)?.toInt(),
  json['event'] == null
      ? null
      : Event.fromJson(json['event'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FavoritesToJson(Favorites instance) => <String, dynamic>{
  'customerFavoriteEventID': instance.customerFavoriteEventID,
  'event': instance.event,
};
