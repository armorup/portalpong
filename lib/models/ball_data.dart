import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:portalpong/models/stream_list.dart';
import 'package:uuid/uuid.dart';

part 'ball_data.g.dart';

@JsonSerializable(explicitToJson: true)
class BallData with HasId {
  @override
  late String id;
  String curOwnerId;
  String prevOwnerId;
  bool isEntering;
  double posFromStart;
  double xVel;
  double yVel;

  BallData({
    required this.curOwnerId,
    this.prevOwnerId = '',
    this.isEntering = false,
    this.posFromStart = 0,
    this.xVel = 0,
    this.yVel = 0,
  }) {
    id = const Uuid().v4();
  }

  @JsonKey(ignore: true)
  Vector2 get velocity => Vector2(xVel, yVel);
  set velocity(Vector2 vect) {
    xVel = vect.x;
    yVel = vect.y;
  }

  factory BallData.fromJson(Map<String, dynamic> json) =>
      _$BallDataFromJson(json);
  Map<String, dynamic> toJson() => _$BallDataToJson(this);
}
