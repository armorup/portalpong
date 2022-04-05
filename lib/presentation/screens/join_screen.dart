import 'package:avatars/avatars.dart';
import 'package:flutter/material.dart';
import '../../domain/network/client.dart';
import '../../domain/network/network.dart';
import '../../domain/network/server.dart';
import '../../game.dart';
import '../../main.dart';

class JoinScreen extends StatelessWidget {
  const JoinScreen({required this.game, Key? key}) : super(key: key);
  final PortalPongGame game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Avatar(
                  name: data.player.name,
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: (net.server != null)
                      ? null
                      : () async {
                          await hostGame();
                        },
                  child: const Text('Host Game'),
                ),
                ElevatedButton(
                  child: const Text('Join Game'),
                  onPressed: (net.client == null)
                      ? () async {
                          joinGame();
                        }
                      : null,
                ),
                ElevatedButton(
                  child: const Text('Logout'),
                  onPressed: (net.client == null) ? logout : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void logout() {
    game.overlays.add('login');
    game.overlays.remove('join');
  }

  Future<void> hostGame() async {
    net.server = Server();
    await net.server!.start();
    joinGame();
  }

  void joinGame() {
    // net.client = Client(player: data.player);
    // net.client!.start();
    game.overlays.add('wait');
    game.overlays.remove('join');
  }
}
