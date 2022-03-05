import 'package:avatars/avatars.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalpong/game.dart';
import 'package:portalpong/player.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({Key? key}) : super(key: key);
  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
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
                    StreamBuilder(
                        stream: game.playersStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<Player> players =
                                snapshot.data as List<Player>;
                            return ListView.builder(
                              itemCount: players.length,
                              itemBuilder: (context, i) =>
                                  Avatar(name: players[i].name),
                            );
                          } else {
                            return Avatar(
                              name: game.player!.name,
                            );
                          }
                        }),
                    const SizedBox(height: 50),
                    if (game.server != null)
                      ElevatedButton(
                          onPressed: () {
                            context.go('/game');
                          },
                          child: const Text('Launch!')),
                    ElevatedButton(
                      onPressed: () async {
                        cancel();
                        context.pop();
                      },
                      child: const Text('Cancel'),
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

  void cancel() async {
    // stop the server if it exists
    await game.server?.stop();
    game.server = null;
    // stop trying to join
    await game.client?.cancel();
    game.client = null;
  }
}
