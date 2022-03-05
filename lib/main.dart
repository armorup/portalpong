import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portalpong/game.dart';
import 'package:portalpong/screens/join_screen.dart';
import 'package:portalpong/screens/login_screen.dart';
import 'package:portalpong/screens/waiting_screen.dart';

// Single instance of player and game data here
// late PlayerData playerData;
// late GameData gameData;

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
      home: App(),
    ),
  );
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
      );

  final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/join',
        builder: (context, state) => const JoinScreen(),
      ),
      GoRoute(
        path: '/wait',
        builder: (context, state) => const WaitingScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameLoader(),
      )
    ],
  );
}
