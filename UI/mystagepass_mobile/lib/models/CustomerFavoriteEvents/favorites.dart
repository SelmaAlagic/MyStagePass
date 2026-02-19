import 'package:json_annotation/json_annotation.dart';
import '../Event/event.dart';

part 'favorites.g.dart';

@JsonSerializable()
class Favorites {
  int? customerFavoriteEventID;
  Event? event;

  Favorites(this.customerFavoriteEventID, this.event);

  factory Favorites.fromJson(Map<String, dynamic> json) =>
      _$FavoritesFromJson(json);
  Map<String, dynamic> toJson() => _$FavoritesToJson(this);
}
