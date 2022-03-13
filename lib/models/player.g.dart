// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
      json['name'] as String,
      posFromStart: (json['posFromStart'] as num?)?.toDouble() ?? 0,
      xVel: (json['xVel'] as num?)?.toDouble() ?? 0,
      yVel: (json['yVel'] as num?)?.toDouble() ?? 0,
      launch: json['launch'] as bool? ?? false,
      dropTime: json['dropTime'] as int? ?? 2000,
      whoHasBall: json['whoHasBall'] as String? ?? '',
      prevWhoHasBall: json['prevWhoHasBall'] as String? ?? '',
    );

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
      'name': instance.name,
      'launch': instance.launch,
      'dropTime': instance.dropTime,
      'whoHasBall': instance.whoHasBall,
      'prevWhoHasBall': instance.prevWhoHasBall,
      'posFromStart': instance.posFromStart,
      'xVel': instance.xVel,
      'yVel': instance.yVel,
    };
