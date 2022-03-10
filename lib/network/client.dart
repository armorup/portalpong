// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:portalpong/game.dart';
import 'package:portalpong/network/network.dart';
import 'package:portalpong/models/player.dart';
import 'package:portalpong/network/udpclient.dart';
import 'package:portalpong/network/wsclient.dart';

class Client {
  late WSClient _wsClient;
  late UDPClient _udpClient;

  late PlayersList players;
  late Timer _pingTimer;

  // True if this is also the host device
  bool get isHost => net.server != null;

  Client() {
    players = PlayersList(initialPlayer: game.player!);
    _wsClient = WSClient(playersCallback: players.read);
    _udpClient = UDPClient(connectTo: _wsClient.connectTo);
  }

  /// Start the client to begin joining process
  void start() async {
    await _udpClient.connect();
    // TODO: ping playerlist to all players - only if this client connects
    // _pingTimer = Timer.periodic(
    //   const Duration(milliseconds: 500),
    //   (timer) => pingPlayers(),
    // );
  }

  /// Update network with message
  void writePlayer(Player player) =>
      _wsClient.write(jsonEncode(player.toJson()));

  void write(json) => _wsClient.write(json);

  /// Host should update other players of players list
  void pingPlayers() {
    for (var player in players.players) {
      _wsClient.write(jsonEncode(player.toJson()));
    }
  }

  /// End client connection
  Future<void> cancel() async {
    // remove player from server
    _udpClient.cancel();
    _wsClient.cancel();
    //_pingTimer.cancel();
  }
}

class PlayersList {
  final _players = <String, Player>{};
  final _controller = StreamController();
  List<Player> get players => _players.values.toList();

  // Clear and add local player to players list
  PlayersList({required Player initialPlayer}) {
    _initPlayers(initialPlayer);
  }

  // Return a stream of all players in the game
  Stream<List<Player>> get stream => _controller.stream.map(
        (playersMap) => playersMap.values.toList(),
      );

  /// Called when player information is received from stream
  void read(playerJson) {
    Player player = Player.fromJson(jsonDecode(playerJson));
    print(player.name);
    //if (_players.containsKey(player.name)) return;
    _players.putIfAbsent(player.name, () => player);
    // This adds to local stream of players
    _controller.sink.add(_players);
  }

  void _initPlayers(Player player) {
    _players.clear();
    _players.putIfAbsent(player.name, () => player);
  }
}
