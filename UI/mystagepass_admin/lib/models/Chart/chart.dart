import 'package:json_annotation/json_annotation.dart';

part 'chart.g.dart';

@JsonSerializable()
class Chart {
  String? name;
  int? value;

  Chart({this.name, this.value});

  factory Chart.fromJson(Map<String, dynamic> json) => _$ChartFromJson(json);

  Map<String, dynamic> toJson() => _$ChartToJson(this);
}
