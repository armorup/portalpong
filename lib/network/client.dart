// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:portalpong/game.dart';
import 'package:portalpong/game_state.dart';
import 'package:portalpong/models/ball_model.dart';
import 'package:portalpong/network/network.dart';
import 'package:portalpong/models/player.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Client {
  late WSClient _wsClient;
  late UDPClient _udpClient;

  late PlayersList players;
  late Timer _pingTimer;

  // True if this is also the host device
  bool get isHost => game.server != null;

  Client() {
    players = PlayersList();
    _wsClient = WSClient(playersCallback: players.read);
    _udpClient = UDPClient(connectTo: _wsClient.connectTo);
  }

  /// Start the client to begin joining process
  void start() async {
    _udpClient.connect();
    _pingTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) => pingPlayers(),
    );
  }

  /// Update network with message
  void push(message) => _wsClient.channel?.sink.add(message);

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
    _pingTimer.cancel();
  }
}

/// Join websocket server
class WSClient {
  WebSocketChannel? channel;
  StreamSubscription? _sub;

  // The function to call when listening to player joins
  late void Function(dynamic json) playersCallback;
  WSClient({required this.playersCallback});

  /// Connect and begin listening
  Future<void> connectTo(String address, int port) async {
    channel = WebSocketChannel.connect(Uri.parse('ws://$address:$port'));
    _sub = channel!.stream.listen((json) {
      if (GameState.playState == PlayState.joining) {
        print(json);
        playersCallback(json);
      } else if (GameState.playState == PlayState.inGame) {
        updateGame(json);
      }
    });
    // add current player
    write(game.player!.toJson());
    //channel!.sink.add(jsonEncode(game.player!.toJson()));
    print('${game.player!.name} joined @$address:$port');
  }

  /// Write data to ws stream
  void write(json) {
    if (GameState.playState == PlayState.joining) {
      channel!.sink.add(jsonEncode(json));
    }
    print('Invalid json: ' + json);
  }

  /// Update game info
  void updateGame(gameJson) {}

  void cancel() {
    _sub?.cancel();
    channel = null;
  }
}

/// Client for joining an existing local server
class UDPClient {
  /// The callback to call when server ip and port is found
  Future<void> Function(String ip, int port) connectTo;
  StreamSubscription<RawSocketEvent>? _udpSub;

  UDPClient({required this.connectTo});

  /// Call this first for client to search for and join server
  Future<void> connect() async {
    var udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    udpSocket.broadcastEnabled = true;
    print('Client:${udpSocket.address.address}:${udpSocket.port}');

    // listen for response from server
    _udpSub = udpSocket.listen(
      (e) {
        Datagram? datagram = udpSocket.receive();
        if (datagram == null) return;
        String response = String.fromCharCodes(datagram.data);
        print(
            "Client received: $response ${datagram.address.address}:${datagram.port}");
        // connect to websocket server
        if (response == acceptKey) {
          String address = datagram.address.address;
          int port = datagram.port;
          connectTo(address, port);
        }
      },
      onError: (e) => udpSocket.close(),
      onDone: () => udpSocket.close(),
    );

    udpSocket.send(joinKey.codeUnits, network.broadcastIP, network.port);
  }

  void cancel() {
    _udpSub?.cancel();
  }
}

class PlayersList {
  final _players = <String, Player>{};
  final _controller = StreamController();
  List<Player> get players => _players.values.toList();

  // Clear and add local player to players list
  PlayersList() {
    _initPlayers();
  }

  // Return a stream of all players in the game
  Stream<List<Player>> get stream => _controller.stream.map(
        (playersMap) => playersMap.values.toList(),
      );

  /// Called when player information is received from stream
  void read(playerJson) {
    Player player = Player.fromJson(jsonDecode(playerJson));
    print(player.name);
    if (_players.containsKey(player.name)) return;
    _players.putIfAbsent(player.name, () => player);
    // add list of players
    _controller.sink.add(_players);
  }

  void _initPlayers() {
    _players.clear();
    _players.putIfAbsent(game.player!.name, () => game.player!);
  }
}

// The information to send over the network
class GameNetworkData {
  // The player that should receive the ball
  Player player;
  BallModel ball;
  GameNetworkData({required this.player, required this.ball});
}
