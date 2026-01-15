import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'userID')
  int? userId;
  String? firstName;
  String? lastName;
  String? email;
  String? role;
  bool? isActive;

  User({
    this.userId,
    this.firstName,
    this.lastName,
    this.email,
    this.role,
    this.isActive,
  });

  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
