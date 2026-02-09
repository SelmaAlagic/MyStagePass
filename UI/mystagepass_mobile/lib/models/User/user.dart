import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int? userId;
  String? email;
  String? role;
  String? username;
  String? firstName;
  String? lastName;
  String? fullName;

  User(
    this.userId,
    this.email,
    this.role,
    this.username,
    this.firstName,
    this.lastName,
    this.fullName,
  );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
