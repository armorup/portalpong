import 'package:json_annotation/json_annotation.dart';

part 'player.g.dart';

@JsonSerializable()
class Player {
  String name;
  bool launch;
  int dropTime;

  String whoHasBall; // Which player has the ball?
  bool entering; // is the ball entering the play area?
  bool exiting;
  double posFromStart;
  double xVel; // ball x velocity
  double yVel; // ball y velocity

  Player(
    this.name, {
    this.posFromStart = 0,
    this.xVel = 0,
    this.yVel = 0,
    this.launch = false,
    this.dropTime = 2,
    this.whoHasBall = '',
    this.entering = false,
    this.exiting = true,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
