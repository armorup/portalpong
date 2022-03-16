import 'package:json_annotation/json_annotation.dart';
import 'package:portalpong/models/stream_list.dart';
import 'package:uuid/uuid.dart';

part 'player.g.dart';

@JsonSerializable(explicitToJson: true)
class Player with HasId {
  @override
  late String id;
  String name;
  bool launch;
  int dropTime;

  Player(
    this.name, {
    this.launch = false,
    this.dropTime = 2000,
  }) {
    id = const Uuid().v4();
  }

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);
}
