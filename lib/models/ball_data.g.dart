// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ball_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BallData _$BallDataFromJson(Map<String, dynamic> json) => BallData(
      curOwner: json['curOwner'] as String,
      prevOwner: json['prevOwner'] as String? ?? '',
      isEntering: json['isEntering'] as bool? ?? false,
      posFromStart: (json['posFromStart'] as num?)?.toDouble() ?? 0,
      xVel: (json['xVel'] as num?)?.toDouble() ?? 0,
      yVel: (json['yVel'] as num?)?.toDouble() ?? 0,
    )..id = json['id'] as String;

Map<String, dynamic> _$BallDataToJson(BallData instance) => <String, dynamic>{
      'id': instance.id,
      'curOwner': instance.curOwner,
      'prevOwner': instance.prevOwner,
      'isEntering': instance.isEntering,
      'posFromStart': instance.posFromStart,
      'xVel': instance.xVel,
      'yVel': instance.yVel,
    };
