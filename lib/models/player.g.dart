// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      json['name'] as String,
      launch: json['launch'] as bool? ?? false,
      dropTime: json['dropTime'] as int? ?? 2000,
    )..id = json['id'] as String;

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'launch': instance.launch,
      'dropTime': instance.dropTime,
    };
