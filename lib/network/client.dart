// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:portalpong/game.dart';
import 'package:portalpong/models/players_list.dart';
import 'package:portalpong/network/network.dart';
import 'package:portalpong/models/player.dart';
import 'package:portalpong/network/udpclient.dart';
import 'package:portalpong/network/wsclient.dart';

class Client {
  late WSClient _wsClient;
  late UDPClient _udpClient;
  late PlayersList playersList;

  final int dropTime = 2000;

  bool get isHost => net.server != null; // True if this is the host device

  Client() {
    playersList = PlayersList(initialPlayer: game.player!);
    _wsClient = WSClient(callback: read);
    _udpClient = UDPClient(connectTo: _wsClient.connectTo);
  }

  /// Start the client to begin joining process
  void start() async {
    await _udpClient.connect();
    // Poll for and remove disconnected players from list
    // startTimers();
  }

  /// Start timers to poll and check if network player disconnected
  void startTimers() {
    Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) => write(jsonEncode(game.player!.toJson())),
    );

    // If player has disconnected, drop them from list
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      for (var player in playersList.players) {
        player.dropTime -= 500;
        if (player.dropTime <= 0) {
          playersList.remove(player);
        }
      }
    });
  }

  /// Update network with Player
  void write(playerJson) => _wsClient.write(playerJson);

  /// Write game data
  //void writeGame(GameData data) => _wsClient.write(jsonEncode(data.toJson()));

  /// Read Player data  from network
  void read(playerJson) {
    Player player = Player.fromJson(jsonDecode(playerJson));
    player.dropTime = dropTime;
    print(player.name);
    playersList.updateList(player);
    if (isHost) {
      pingPlayers();
    }

    if (game.state == GameState.playing && game.portal != null) {
      if (game.player!.whoHasBall == game.player!.name) {
        var impulse = Vector2(-player.xVel, -player.yVel);
        var x =
            game.portal!.position.x + game.portal!.width * player.posFromStart;
        var y = game.portal!.position.y;
        var pos = Vector2(x, y);
        game.addBall(pos, impulse);
      }
    }
  }

  /// Read game data
  // void readGame(gameJson) {
  //   GameData data = GameData.fromJson(jsonDecode(gameJson));
  // }

  /// Host should update other players of players list
  void pingPlayers() {
    for (var player in playersList.players) {
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
