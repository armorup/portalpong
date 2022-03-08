// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'package:flame/game.dart';
import 'package:portalpong/game_objects/balls.dart';
import 'package:portalpong/network/client.dart';
import 'package:portalpong/network/server.dart';
import 'package:portalpong/game_objects/paddle.dart';
import 'package:portalpong/models/player.dart';
import 'game_objects/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

PortalPongGame game = PortalPongGame();

class GameLoader extends StatelessWidget {
  const GameLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GameWidget(
        // Create the game
        game: game,
        loadingBuilder: (context) => const Material(
          child: Center(child: CircularProgressIndicator()),
        ),
        errorBuilder: (context, ex) {
          debugPrint(ex.toString());
          return const Material(
            child: Center(
              child: Text('Something went wrong. Reload me'),
            ),
          );
        },
        //overlayBuilderMap: {},
      ),
    );
  }
}

/// The game
class PortalPongGame extends Forge2DGame with TapDetector {
  PortalPongGame() : super(gravity: Vector2(0, 0));

  Server? server; // null if this user is not the game host
  Client? client;
  Player? player;
  final players = <String, Player>{};
  final _controller = StreamController<Map<String, Player>>();

  void addPlayer(String name) {
    player = Player(name);
    players.putIfAbsent(name, () => player!);
  }

  Stream<List<Player>> get playersStream => _controller.stream.map(
        (playersMap) => playersMap.values.toList(),
      );

  Paddle? paddle;
  late Body groundBody;
  MouseJoint? mouseJoint;
  final timer = Timer(2);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);

    final bgSprite = await Sprite.load('background.png');
    final bg = SpriteComponent(sprite: bgSprite);
    add(bg);

    final center = screenToWorld(camera.viewport.effectiveSize / 2);
    groundBody = world.createBody(BodyDef());

    var ball = Ball(center);
    add(ball);
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    if (paddle != null) {
      game.remove(paddle!);
      paddle = null;
    }
    paddle = Paddle(info.eventPosition.game);
    add(paddle!);
  }
}

class Portal {}
