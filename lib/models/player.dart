import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable(explicitToJson: true)
class Player {
  String name;
  bool launch;
  int dropTime;

  Player(
    this.name, {
    this.launch = false,
    this.dropTime = 2000,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
