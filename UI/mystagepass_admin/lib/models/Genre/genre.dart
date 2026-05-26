import 'package:json_annotation/json_annotation.dart';

part 'genre.g.dart';

@JsonSerializable()
class Genre {
  @JsonKey(name: 'genreID')
  int? genreId;
  String? name;
  List<String>? performers;

  Genre({this.genreId, this.name, this.performers});

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);
  Map<String, dynamic> toJson() => _$GenreToJson(this);
}
