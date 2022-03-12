import 'dart:async';
import 'dart:convert';

import 'package:avatars/avatars.dart';
import 'package:flutter/material.dart';
import 'package:portalpong/game.dart';
import 'package:portalpong/models/player.dart';
import 'package:portalpong/network/network.dart';

class WaitScreen extends StatefulWidget {
  const WaitScreen({required this.game, Key? key}) : super(key: key);
  final PortalPongGame game;

  @override
  State<WaitScreen> createState() => _WaitScreenState();
}

class _WaitScreenState extends State<WaitScreen> {
  var stream = net.client!.playersList.stream.asBroadcastStream();
  StreamSubscription<List<Player>>? sub;
  @override
  Widget build(BuildContext context) {
    startLaunchListener(stream);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder(
                  stream: stream,
                  initialData: [game.player!],
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Player> players = snapshot.data as List<Player>;
                      return Expanded(
                        child: ListView.builder(
                          itemCount: players.length,
                          itemBuilder: (context, i) {
                            return Avatar(name: players[i].name);
                          },
                        ),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),
              const SizedBox(height: 50),
              if (net.server != null)
                ElevatedButton(
                    onPressed: () {
                      game.player!.launch = true;
                      // The player who clicks this button starts with ball
                      game.player!.whoHasBall = game.player!.name;
                      net.client!.write(jsonEncode(game.player!.toJson()));
                      //game.player!.launch = false;
                      game.startGame();
                      game.overlays.remove('wait');
                    },
                    child: const Text('Launch!')),
              ElevatedButton(
                onPressed: () async {
                  cancel();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startLaunchListener(Stream<List<Player>> stream) {
    sub ??= stream.listen((players) {
      for (var player in players) {
        if (player.launch) {
          game.startGame();
          game.overlays.remove('wait');
          sub!.pause();
          break;
        }
      }
    });
    if (sub!.isPaused) sub!.resume();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    sub!.cancel();
    sub = null;
    super.dispose();
  }

  void cancel() async {
    // stop the server if it exists
    await net.server?.cancel();
    net.server = null;
    // stop trying to join
    await net.client?.cancel();
    net.client = null;

    game.overlays.add('join');
    game.overlays.remove('wait');
  }
}
