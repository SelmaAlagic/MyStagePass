import 'package:json_annotation/json_annotation.dart';
import '../User/user.dart';

part 'performer.g.dart';

@JsonSerializable()
class Performer {
  int? performerID;
  bool? isApproved;
  User? user;

  Performer(this.performerID, this.isApproved, this.user);

  factory Performer.fromJson(Map<String, dynamic> json) =>
      _$PerformerFromJson(json);
  Map<String, dynamic> toJson() => _$PerformerToJson(this);
}
