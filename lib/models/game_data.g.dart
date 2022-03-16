// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameData _$GameDataFromJson(Map<String, dynamic> json) => GameData(
      player: Player.fromJson(json['player'] as Map<String, dynamic>),
    )..ballData = BallData.fromJson(json['ballData'] as Map<String, dynamic>);

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
      'player': instance.player.toJson(),
      'ballData': instance.ballData.toJson(),
    };
