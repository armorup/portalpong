import 'package:faker/faker.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:portalpong/game.dart';
import 'package:portalpong/models/game_data.dart';
import 'package:portalpong/models/player.dart';

// Single instance of player and game data here
GameData data =
    GameData(player: Player('Guest${random.integer(1000000, min: 100000)}'));

ThemeData themeData = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.lightBlue,
  scaffoldBackgroundColor: Colors.white,
  backgroundColor: Colors.blueAccent,
  fontFamily: 'Calibri',
  textTheme: const TextTheme(
    headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
    headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
    bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Arial'),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();

  // Load game data
  // var json = await rootBundle
  //     .loadString('assets/game_data.json')
  //     .then((value) => jsonDecode(value));
  // gameData = GameData.fromJson(json);

  // Load saved data
  // var prefs = await SharedPreferences.getInstance();

  // if (prefs.containsKey('data')) {
  //   playerData = PlayerData.fromJson(
  //     jsonDecode(prefs.get('data').toString()),
  //   );
  // } else {
  //   playerData = PlayerData();
  // }

  runApp(
    MaterialApp(
      title: 'Portal Pong',
      //themeMode: ThemeMode.system,
      theme: themeData,
      home: const GameLoader(),
    ),
  );
}
