import 'dart:async';

import 'package:portalpong/models/player.dart';

/// List of players in the game
class PlayersList {
  final _players = <String, Player>{};
  final _controller = StreamController.broadcast();
  List<Player> get players => _players.values.toList();

  // Clear and add local player to players list
  PlayersList({required Player initialPlayer}) {
    _controller.stream.asBroadcastStream();
    _initPlayers(initialPlayer);
  }

  // Return a stream of all players in the game
  Stream<List<Player>> get stream => _controller.stream.map(
        (playersMap) => playersMap.values.toList(),
      );

  void updateList(Player player) {
    _players.update(
      player.name,
      (value) => player,
      ifAbsent: () => player,
    );
    _controller.sink.add(_players);
  }

  void remove(Player player) {
    _players.remove(player);
    _controller.sink.add(_players);
  }

  void _initPlayers(Player player) {
    _players.clear();
    _players.putIfAbsent(player.name, () => player);
  }
}
