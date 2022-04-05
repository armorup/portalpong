// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:portalpong/domain/network/network.dart';

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
          _udpSub!.cancel();
        }
      },
      onError: (e) {
        print(e);
        udpSocket.close();
      },
      onDone: () {
        print('done');
        udpSocket.close();
      },
    );

    udpSocket.send(joinKey.codeUnits, net.broadcastIP, net.port);
  }

  void cancel() {
    _udpSub?.cancel();
  }
}
