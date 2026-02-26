import 'package:json_annotation/json_annotation.dart';
import '../Ticket/ticket.dart';

part 'purchase.g.dart';

@JsonSerializable()
class Purchase {
  int? purchaseID;
  DateTime? purchaseDate;
  int? customerID;
  List<Ticket>? tickets;
  bool? isDeleted;
  int? total;

  Purchase({
    this.purchaseID,
    this.purchaseDate,
    this.customerID,
    this.tickets,
    this.isDeleted,
    this.total,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) =>
      _$PurchaseFromJson(json);
  Map<String, dynamic> toJson() => _$PurchaseToJson(this);
}
