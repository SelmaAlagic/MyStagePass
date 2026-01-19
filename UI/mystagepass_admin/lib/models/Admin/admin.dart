import 'package:json_annotation/json_annotation.dart';
import '../User/user.dart';
part 'admin.g.dart';

@JsonSerializable()
class Admin {
  int? adminID;

  User? user;

  Admin(this.adminID, this.user);

  factory Admin.fromJson(Map<String, dynamic> json) => _$AdminFromJson(json);

  Map<String, dynamic> toJson() => _$AdminToJson(this);
}
