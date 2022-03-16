// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:portalpong/game.dart';
import 'package:portalpong/main.dart';
import 'package:portalpong/models/ball_data.dart';
import 'package:portalpong/models/game_data.dart';
import 'package:portalpong/models/player.dart';
import 'package:portalpong/models/stream_list.dart';
import 'package:portalpong/network/network.dart';
import 'package:portalpong/network/udpclient.dart';
import 'package:portalpong/network/wsclient.dart';

class Client {
  late WSClient _wsClient;
  late UDPClient _udpClient;
  late StreamList<Player> playersList;
  late StreamList<BallData> ballDataList;
  final Player player;
  final int dropTime = 2000;

  bool get isHost => net.server != null; // True if this is the host device

  Client({required this.player}) {
    _wsClient = WSClient(callback: read);
    _udpClient = UDPClient(connectTo: _wsClient.connectTo);
    _init();
  }

  /// Add player to list
  void _init() {
    playersList = StreamList(initialValue: player);
    ballDataList = StreamList(initialValue: data.ballData);
    if (isHost) {
      data.ballData.curOwner = player.name;
    }
  }

  /// Start the client to begin joining process
  void start() async {
    await _udpClient.connect();
    // Poll for and remove disconnected players from list
    // startTimers();
  }

  /// Start timers to poll and check if network player disconnected
  void _startTimers() {
    Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) => write(),
    );

    // If player has disconnected, drop them from list
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      for (var player in playersList.list) {
        player.dropTime -= 500;
        if (player.dropTime <= 0) {
          playersList.remove(player);
        }
      }
    });
  }

  /// Update network with Player
  void write() {
    var json = jsonEncode(data.toJson());
    _wsClient.write(json);
  }

  /// Read data from network
  void read(json) {
    GameData netData = GameData.fromJson(jsonDecode(json));
    print('reading: $json');
    if (netData.player.name == player.name) return;

    if (game.state == GameState.joining) {
      // Host should update everyone when someone joins
      if (isHost) {
        write();
      } else {
        // set everyone's ball owner to be the host player
        data.ballData.curOwner = netData.ballData.curOwner;
      }
      data.player.dropTime = dropTime;
      playersList.update(netData.player);
    }

    // Proceed only if game is playing or multiplayer
    if (game.state == GameState.playing && game.portal != null) {
      // update correct owners
      if (data.ballData.curOwner != netData.ballData.curOwner) {
        data.ballData.curOwner = netData.ballData.curOwner;
        data.ballData.prevOwner = netData.ballData.prevOwner;
        data.ballData.xVel = netData.ballData.xVel;
        data.ballData.yVel = netData.ballData.yVel;
        data.ballData.isEntering = true;
      }
      ballDataList.update(netData.ballData);
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
