// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:portalpong/network/network.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Server {
  late UDPServer udp;
  late WSServer ws;

  Server()
      : udp = UDPServer(),
        ws = WSServer();

  /// Start the servers
  Future<void> start() async {
    await udp.start(); // Listen to join request
    await ws.start(); // Start the main server
  }

  // stop the server
  Future<void> cancel() async {
    udp.cancel();
    ws.cancel();
    print('Stopped @ ws://${network.ip}:${network.port}');
  }
}

/// Main websocket server
class WSServer {
  late HttpServer? http;
  late Handler handler;
  List<StreamSubscription> wsSubs = [];
  List<WebSocketChannel> channels = [];

  WSServer() {
    handler = webSocketHandler((WebSocketChannel wsChannel) {
      if (!channels.contains(wsChannel)) {
        channels.add(wsChannel);
      }
      // broadcast every message heard to all other channels
      var wsSub = wsChannel.stream.listen((message) {
        for (var channel in channels) {
          if (channel != wsChannel) {
            channel.sink.add(message);
          }
        }
        print("handler: $message");
      });
      wsSubs.add(wsSub);
    });
  }

  // The callback when stream is listened to
  void callback(message) {}

  // start websocket server
  Future<void> start() async {
    http = await shelf_io.serve(handler, network.ip, network.port);
    print('Serving @ ws://${network.ip}:${network.port}');
  }

  // ensure server shuts down correctly
  void cancel() async {
    await http?.close();
    for (var sub in wsSubs) {
      sub.cancel();
    }
    channels.clear();
  }
}

/// Start this server to listen to join requests
class UDPServer {
  // The port to listen on, default is the first available port
  late int port;
  late StreamSubscription _udpSub;
  late RawDatagramSocket _udpSocket;
  UDPServer({this.port = 0}) {
    port = network.port;
  }

  /// Broadcast server to listen for join requests
  Future<void> start() async {
    /// bind udp socket to game port
    _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    print('Server:${_udpSocket.address.address}:${_udpSocket.port}');

    // wait for join requests
    _udpSub = _udpSocket.asBroadcastStream().listen(
      (e) {
        Datagram? datagram = _udpSocket.receive();
        if (datagram == null) return;
        // Check if it is a join request
        String request = String.fromCharCodes(datagram.data);
        if (request != joinKey) {
          print('Invalid join request');
          return;
        }
        String clientIp = datagram.address.address;
        int clientPort = datagram.port;
        print("Server received $clientIp:$clientPort");
        _udpSocket.send(
            acceptKey.codeUnits, InternetAddress(clientIp), clientPort);
      },
      onDone: () => _udpSocket.close(),
      onError: (e) => _udpSocket.close(),
    );
  }

  void cancel() {
    _udpSub.cancel();
    _udpSocket.close();
  }
}
