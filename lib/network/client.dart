// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:portalpong/game.dart';
import 'package:portalpong/network/network.dart';
import 'package:portalpong/player.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Client {
  WebSocketChannel? _channel;
  StreamSubscription<RawSocketEvent>? _udpSub;

  /// Stream of player updates
  Stream<Player> get stream =>
      _channel!.stream.map((json) => Player.fromJson(jsonDecode(json)));

  /// Update player to network
  void sink() {
    _channel!.sink.add(jsonEncode(game.player!.toJson()));
  }

  /// Connect and begin listening
  Future<void> connectTo(String address, int port) async {
    _channel = WebSocketChannel.connect(Uri.parse('ws://$address:$port'));
    _channel!.stream.listen((playerJson) {
      Player player = Player.fromJson(jsonDecode(playerJson));
      print(player.name);
      game.addPlayer(player);
    });
    _channel!.sink.add(jsonEncode(game.player!.toJson()));
    print('${game.player!.name} joined @$address:$port');
  }

  /// End client connection
  Future<void> cancel() async {
    // remove player from server
    _udpSub?.cancel();
    _udpSub = null;
    _channel = null;
  }

  /// Call this first for client to search for and join server
  Future<void> connect() async {
    // connectTo('10.115.137.49', 8080);
    var udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    udpSocket.broadcastEnabled = true;
    print('Client:${udpSocket.address.address}:${udpSocket.port}');

    // listen for response from server
    _udpSub = udpSocket.listen(
      (e) {
        Datagram? datagram = udpSocket.receive();
        if (datagram == null) return;
        String response = String.fromCharCodes(datagram.data);
        print("Client received: $response ${datagram.address.address}");
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
}
