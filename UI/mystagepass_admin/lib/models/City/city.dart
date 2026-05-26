import 'package:json_annotation/json_annotation.dart';
import '../Country/country.dart';
import '../Location/location.dart';
part 'city.g.dart';

@JsonSerializable()
class City {
  @JsonKey(name: 'cityID')
  int? cityId;
  String? name;
  bool? isActive;
  @JsonKey(name: 'countryID')
  int? countryId;
  List<Location>? locations;

  Country? country;

  City({
    this.cityId,
    this.name,
    this.isActive,
    this.countryId,
    this.locations,
    this.country,
  });

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
  Map<String, dynamic> toJson() => _$CityToJson(this);
}
