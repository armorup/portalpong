import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portalpong/domain/repositories/player_repository.dart';

import 'data/models/game_data.dart';
import 'data/models/player.dart';
import 'game.dart';
import 'presentation/screens/wait_screen/bloc/room_bloc.dart';

// Single instance of game data here
GameData data = GameData(player: Player.initial());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  runApp(const MaterialApp(home: App()));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoomBloc(playerStream: FakePlayerRepository()),
      child: const GameScreen(),
    );
  }
}
