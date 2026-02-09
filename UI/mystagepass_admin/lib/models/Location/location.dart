import 'package:json_annotation/json_annotation.dart';
import '../City/city.dart';

part 'location.g.dart';

@JsonSerializable()
class Location {
  @JsonKey(name: 'locationID')
  int? locationId;
  String? locationName;
  int? capacity;
  String? address;
  @JsonKey(name: 'cityID')
  int? cityId;

  City? city;

  Location({
    this.locationId,
    this.locationName,
    this.capacity,
    this.address,
    this.cityId,
    this.city,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
