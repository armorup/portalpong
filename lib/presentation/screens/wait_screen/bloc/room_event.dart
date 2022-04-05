part of 'room_bloc.dart';

@freezed
class RoomEvent with _$RoomEvent {
  const factory RoomEvent.started() = _Started;
  const factory RoomEvent.launch() = _Launch;
  const factory RoomEvent.cancel() = _Cancel;
}
