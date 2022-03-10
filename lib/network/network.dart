import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';
import 'package:portalpong/network/server.dart';

import 'client.dart';

final net = Network();
// For udp join request and response
const String joinKey = 'join';
const String acceptKey = 'ok';

class Network {
  Server? server;
  Client? client;

  String ip = '127.0.0.1';
  final port = 8080;
  String get subnet => ip.substring(0, ip.lastIndexOf('.'));
  InternetAddress get broadcastIP => InternetAddress('$subnet.255');

  // Poll for network stats
  Future<void> poll() async {
    ip = await NetworkInfo().getWifiIP() ?? ip;
  }
}
