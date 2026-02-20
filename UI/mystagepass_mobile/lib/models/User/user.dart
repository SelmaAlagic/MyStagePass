import 'package:json_annotation/json_annotation.dart';
import '../Performer/performer.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int? userID;
  String? email;
  String? role;
  String? username;
  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? image;
  List<Performer>? performers;

  User(
    this.userID,
    this.email,
    this.role,
    this.username,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.image,
    this.performers,
  );

  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
