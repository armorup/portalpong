import 'package:avatars/avatars.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalpong/game.dart';
import 'package:portalpong/network/client.dart';

import '../network/server.dart';

class JoinScreen extends StatelessWidget {
  const JoinScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Avatar(
                      name: game.player!.name,
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: (game.server != null)
                          ? null
                          : () async {
                              game.server = Server();
                              await game.server!.start();
                              joinGame();
                              context.push('/wait');
                            },
                      child: const Text('Host Game'),
                    ),
                    ElevatedButton(
                      child: const Text('Join Game'),
                      onPressed: (game.client == null)
                          ? () async {
                              joinGame();
                              context.push('/wait');
                            }
                          : null,
                    ),
                    ElevatedButton(
                      child: const Text('Logout'),
                      onPressed: (game.client == null)
                          ? () async {
                              context.pop();
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void joinGame() {
    game.client = Client();
    game.client!.connect();
  }
}
