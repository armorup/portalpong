import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';

final network = Network();
// For udp join request and response
const String joinKey = 'join';
const String acceptKey = 'ok';

class Network {
  String ip = '127.0.0.1';
  final port = 8080;

  String get subnet => ip.substring(0, ip.lastIndexOf('.'));
  InternetAddress get broadcastIP => InternetAddress('$subnet.255');

  // Poll for network stats
  Future<void> poll() async {
    ip = await NetworkInfo().getWifiIP() ?? ip;
  }
}
