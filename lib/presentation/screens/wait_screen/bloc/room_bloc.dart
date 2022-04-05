import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:portalpong/domain/repositories/player_repository.dart';
import '../../../../data/models/player.dart';

part 'room_event.dart';
part 'room_state.dart';
part 'room_bloc.freezed.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final PlayerRepository _playerStream;
  final Map<String, Player> _players = {};

  RoomBloc({required PlayerRepository playerStream})
      : _playerStream = playerStream,
        super(const RoomState.initial()) {
    on<RoomEvent>(
      (event, emit) async {
        await event.when(
          started: () => _onStarted(event, emit),
          launch: () => _onLaunch(event, emit),
          cancel: () => _onCancel(event, emit),
        );
      },
      transformer: sequential(),
    );
  }

  // Start listening to incoming players
  Future<void> _onStarted(RoomEvent event, Emitter<RoomState> emit) async {
    emit(const RoomState.loading());
    await emit.forEach(
      _playerStream.stream,
      onData: (Player player) {
        final players = updatePlayerList(player);
        return RoomState.loaded(players);
      },
    );
  }

  // Update the player list
  List<Player> updatePlayerList(Player player) {
    _players.putIfAbsent(player.id, () => player);
    return _players.values.toList();
  }

  Future<void> _onLaunch(RoomEvent event, Emitter<RoomState> emit) async {}
  Future<void> _onCancel(RoomEvent event, Emitter<RoomState> emit) async {}
}
