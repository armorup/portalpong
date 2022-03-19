import 'package:faker/faker.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portalpong/game.dart';
import 'package:portalpong/models/game_data.dart';
import 'package:portalpong/models/player.dart';
import 'package:portalpong/network/client.dart';
import 'package:portalpong/network/network.dart';
import 'package:portalpong/network/server.dart';

// Single instance of game data here
GameData data =
    GameData(player: Player('Guest${random.integer(1000000, min: 100000)}'));

var networkProvider = Provider<Network>((ref) => Network());
var serverProvider =
    Provider<Server?>((ref) => ref.watch(networkProvider).server);
var clientProvider =
    Provider<Client?>((ref) => ref.watch(networkProvider).client);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MaterialApp(
      home: GameLoader(),
    );
  }
}
