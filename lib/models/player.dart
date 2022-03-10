import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable()
class Player {
  String name;

  //TODO refactor to network data
  bool launch;
  double x;
  double y;
  Player(
    this.name, {
    this.x = 0,
    this.y = 0,
    this.launch = false,
  });
  set velocity(Vector2 velocity) {
    x = velocity.x;
    y = velocity.y;
  }

  Vector2 get velocity => Vector2(x, y);

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
