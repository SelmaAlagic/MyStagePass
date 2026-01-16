import 'package:json_annotation/json_annotation.dart';
import '../User/user.dart';

part 'performer.g.dart';

@JsonSerializable()
class Performer {
  @JsonKey(name: 'performerID')
  int? performerId;
  String? artistName;
  String? bio;
  bool? isApproved;
  double? averageRating;

  List<String>? genres;

  User? user;

  Performer({
    this.performerId,
    this.artistName,
    this.bio,
    this.isApproved,
    this.averageRating,
    this.genres,
    this.user,
  });

  String get genresFormatted =>
      genres != null && genres!.isNotEmpty ? genres!.join(', ') : 'No genres';

  factory Performer.fromJson(Map<String, dynamic> json) =>
      _$PerformerFromJson(json);
  Map<String, dynamic> toJson() => _$PerformerToJson(this);
}
