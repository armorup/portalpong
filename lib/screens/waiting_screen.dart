import 'dart:convert';

import 'package:avatars/avatars.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalpong/game.dart';
import 'package:portalpong/models/player.dart';

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder(
                  stream: game.client!.players.stream,
                  initialData: [game.player!],
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Player> players = snapshot.data as List<Player>;
                      return Expanded(
                        child: ListView.builder(
                          itemCount: players.length,
                          itemBuilder: (context, i) =>
                              Avatar(name: players[i].name),
                        ),
                      );
                    } else {
                      return const CircularProgressIndicator();
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
              ElevatedButton(
                onPressed: () async {
                  game.client!.push(
                      jsonEncode(Player(faker.person.firstName()).toJson()));
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void cancel() async {
    // stop the server if it exists
    await game.server?.cancel();
    game.server = null;
    // stop trying to join
    await game.client?.cancel();
    game.client = null;
  }
}
