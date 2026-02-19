import 'package:json_annotation/json_annotation.dart';
import '../City/city.dart';

part 'location.g.dart';

@JsonSerializable()
class Location {
  int? locationID;
  String? locationName;
  int? capacity;
  String? address;

  City? city;

  Location({
    this.locationID,
    this.locationName,
    this.capacity,
    this.address,
    this.city,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}
