// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameData _$GameDataFromJson(Map<String, dynamic> json) => GameData(
      name: json['name'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$GameDataToJson(GameData instance) => <String, dynamic>{
      'name': instance.name,
      'x': instance.x,
      'y': instance.y,
    };
