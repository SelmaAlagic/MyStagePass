import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int? userID;
  String? email;
  String? role;
  String? username;
  String? firstName;
  String? lastName;
  String? fullName;
  String? phoneNumber;
  String? image;

  User(
    this.userID,
    this.email,
    this.role,
    this.username,
    this.firstName,
    this.lastName,
    this.fullName,
    this.phoneNumber,
    this.image,
  );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
