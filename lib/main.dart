import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:portalpong/data/models/game_data.dart';
import 'package:portalpong/data/models/player.dart';
import 'package:portalpong/game.dart';

// Single instance of game data here
GameData data = GameData(player: Player.initial());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameLoader(),
    );
  }
}
