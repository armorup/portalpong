// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:portalpong/game.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Join websocket server
class WSClient {
  WebSocketChannel? channel;
  StreamSubscription? _sub;

  // The function to call when listening to player joins
  late void Function(dynamic json) callback;
  WSClient({required this.callback});

  /// Connect and begin listening
  Future<void> connectTo(String address, int port) async {
    channel = WebSocketChannel.connect(Uri.parse('ws://$address:$port'));
    _sub = channel!.stream.asBroadcastStream().listen(
          (json) => callback(json),
        );
    // add current player
    write(jsonEncode(game.player!.toJson()));
    print('${game.player!.name} joined @$address:$port');
  }

  /// Write data to ws stream
  void write(json) {
    channel!.sink.add(json);
  }

  void cancel() {
    _sub?.cancel();
    channel?.sink.close();
    channel = null;
  }
}
