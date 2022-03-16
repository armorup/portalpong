import 'package:json_annotation/json_annotation.dart';
import 'package:portalpong/models/ball_data.dart';
import 'package:portalpong/models/player.dart';

part 'game_data.g.dart';

@JsonSerializable(explicitToJson: true)
class GameData {
  Player player;
  BallData ballData;

  GameData({
    required this.player,
  }) : ballData = BallData(curOwnerId: player.id);

  factory GameData.fromJson(Map<String, dynamic> json) =>
      _$GameDataFromJson(json);
  Map<String, dynamic> toJson() => _$GameDataToJson(this);
}
