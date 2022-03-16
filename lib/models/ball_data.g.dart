// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ball_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BallData _$BallDataFromJson(Map<String, dynamic> json) => BallData(
      curOwnerId: json['curOwnerId'] as String,
      prevOwnerId: json['prevOwnerId'] as String? ?? '',
      isEntering: json['isEntering'] as bool? ?? false,
      posFromStart: (json['posFromStart'] as num?)?.toDouble() ?? 0,
      xVel: (json['xVel'] as num?)?.toDouble() ?? 0,
      yVel: (json['yVel'] as num?)?.toDouble() ?? 0,
    )..id = json['id'] as String;

Map<String, dynamic> _$BallDataToJson(BallData instance) => <String, dynamic>{
      'id': instance.id,
      'curOwnerId': instance.curOwnerId,
      'prevOwnerId': instance.prevOwnerId,
      'isEntering': instance.isEntering,
      'posFromStart': instance.posFromStart,
      'xVel': instance.xVel,
      'yVel': instance.yVel,
    };
