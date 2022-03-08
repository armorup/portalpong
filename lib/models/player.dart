import 'package:json_annotation/json_annotation.dart';

part '../player.g.dart';

@JsonSerializable()
class Player {
  String name;
  Player(this.name);

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
