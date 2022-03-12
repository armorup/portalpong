import 'package:json_annotation/json_annotation.dart';

part 'game_data.g.dart';

@JsonSerializable()
class GameData {
  String name; // player that has the ball
  double x; // ball x velocity
  double y; // ball y velocity
  GameData({required this.name, required this.x, required this.y});

  factory GameData.fromJson(Map<String, dynamic> json) =>
      _$GameDataFromJson(json);
  Map<String, dynamic> toJson() => _$GameDataToJson(this);
}
