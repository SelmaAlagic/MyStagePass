import 'package:json_annotation/json_annotation.dart';
import '../User/user.dart';

part 'customer.g.dart';

@JsonSerializable()
class Customer {
  int? customerID;
  User? user;

  Customer(this.customerID, this.user);

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}
