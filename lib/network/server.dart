// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:portalpong/network/network.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

class Server {
  HttpServer? http;
  StreamSubscription? udpSub;

  // handle websocket requests
  Handler handler = webSocketHandler((webSocket) {
    webSocket.stream.listen((message) {
      webSocket.sink.add(message);
    });
  });

  /// Start listening to join request udp
  /// Start the ws server
  Future<void> start() async {
    await startUDP();
    await startWS();
  }

  // start websocket server
  Future<void> startWS() async {
    http = await shelf_io.serve(handler, network.ip, network.port);
    print('Serving @ ws://${network.ip}:${network.port}');
  }

  // stop the server
  Future<void> stop() async {
    await http?.close();
    udpSub?.cancel();
    print('Stopped @ ws://${network.ip}:${network.port}');
  }

  /// Broadcast server to listen for join requests
  Future<void> startUDP() async {
    /// bind udp socket to game port
    var socket =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, network.port);
    print('Server:${socket.address.address}:${socket.port}');

    // wait for join requests
    udpSub = socket.listen(
      (e) {
        Datagram? datagram = socket.receive();
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
        socket.send(acceptKey.codeUnits, InternetAddress(clientIp), clientPort);
      },
      onDone: () => socket.close(),
      onError: (e) => socket.close(),
    );
  }
}
