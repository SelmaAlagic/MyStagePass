import 'package:json_annotation/json_annotation.dart';
import '../Event/event.dart';

part 'status.g.dart';

@JsonSerializable()
class Status {
  int? statusId;
  String? statusName;
  List<Event>? events;

  Status({this.statusId, this.statusName, this.events});

  factory Status.fromJson(Map<String, dynamic> json) => _$StatusFromJson(json);
  Map<String, dynamic> toJson() => _$StatusToJson(this);
}
