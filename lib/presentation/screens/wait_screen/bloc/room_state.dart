part of 'room_bloc.dart';

@freezed
class RoomState with _$RoomState {
  const factory RoomState.initial() = _Initial;
  const factory RoomState.loading() = _Loading;
  const factory RoomState.loaded(List<Player> players) = _Loaded;
}
