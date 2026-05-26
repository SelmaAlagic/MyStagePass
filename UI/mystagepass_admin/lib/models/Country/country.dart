import 'package:json_annotation/json_annotation.dart';
import '../City/city.dart';

part 'country.g.dart';

@JsonSerializable()
class Country {
  @JsonKey(name: 'countryID')
  int? countryId;
  String? name;
  bool? isActive;
  List<City>? cities;

  Country({this.countryId, this.name, this.isActive, this.cities});

  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);
  Map<String, dynamic> toJson() => _$CountryToJson(this);
}
