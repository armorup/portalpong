import 'package:json_annotation/json_annotation.dart';
import 'package:portalpong/models/stream_list.dart';
import 'package:uuid/uuid.dart';

part 'ball_data.g.dart';

@JsonSerializable(explicitToJson: true)
class BallData with HasId {
  @override
  late String id;
  String curOwner;
  String prevOwner;
  bool isEntering;
  double posFromStart;
  double xVel;
  double yVel;
  BallData(
      {required this.curOwner,
      this.prevOwner = '',
      this.isEntering = false,
      this.posFromStart = 0,
      this.xVel = 0,
      this.yVel = 0}) {
    id = const Uuid().v4();
  }

  factory BallData.fromJson(Map<String, dynamic> json) =>
      _$BallDataFromJson(json);
  Map<String, dynamic> toJson() => _$BallDataToJson(this);
}
