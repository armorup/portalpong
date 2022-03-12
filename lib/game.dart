// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'package:flame/game.dart';
import 'package:portalpong/game_objects/balls.dart';
import 'package:portalpong/game_objects/paddle.dart';
import 'package:portalpong/game_objects/portal.dart';
import 'package:portalpong/models/player.dart';
import 'package:portalpong/network/network.dart';
import 'package:portalpong/screens/join_screen.dart';
import 'package:portalpong/screens/login_screen.dart';
import 'package:portalpong/screens/wait_screen.dart';
import 'game_objects/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

/// One instance of the game
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
        overlayBuilderMap: {
          'login': (context, PortalPongGame game) => LoginScreen(game: game),
          'join': (context, PortalPongGame game) => JoinScreen(game: game),
          'wait': (context, PortalPongGame game) => WaitScreen(game: game),
        },
      ),
    );
  }
}

enum GameState { joining, playing }

/// The game
class PortalPongGame extends Forge2DGame with MultiTouchDragDetector {
  PortalPongGame() : super(gravity: Vector2(0, 0));

  Player? player;
  late Paddle paddle;
  Portal? portal;
  GameState state = GameState.joining;

  // Map player name with their paddle
  //Map<String, Paddle> otherPlayers = {};
  //StreamSubscription<List<Player>>? sub;

  late Ball ball;
  late SpriteComponent background;
  bool dragValid = false;

  late Body groundBody;
  MouseJoint? mouseJoint;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    overlays.add('login');
  }

  void startGame() async {
    await setup();
    add(background);
    add(paddle);
    if (portal != null) {
      add(portal!);
    }
    state = GameState.playing;
  }

  // void updateOthers() {
  //   final center = screenToWorld(camera.viewport.effectiveSize / 2);
  //   sub = net.client!.playersList.stream.listen((players) {
  //     for (var player in players) {
  //       String name = player.name;
  //       var x = player.x;
  //       var y = player.y;
  //       Paddle paddle;
  //       if (!otherPlayers.containsKey(name)) {
  //         paddle = otherPlayers.putIfAbsent(name, () => Paddle.other(center));
  //         add(paddle);
  //       }
  //       paddle = otherPlayers[name]!;
  //       paddle.body.applyLinearImpulse(Vector2(x, y));
  //     }
  //   });
  // }

  Future<void> setup() async {
    // Background
    final bgSprite = await Sprite.load('background.png');
    background = SpriteComponent(sprite: bgSprite);
    groundBody = world.createBody(BodyDef());

    // If other player exists, add a portal
    bool topBoundary = true;
    var players = net.client!.playersList.players;
    if (players.length > 1) {
      topBoundary = false;
      var portalOwner = net.client!.playersList.players
          .firstWhere((other) => other.name != player!.name);
      // Add opponent portals
      var portalPos = screenToWorld(Vector2(0, 30));
      var portalwidth = screenToWorld(camera.viewport.effectiveSize).x;
      portal = Portal(
        owner: portalOwner,
        position: portalPos,
        width: portalwidth,
      );
      addContactCallback(PortalContactCallback());
    }

    final boundaries = createBoundaries(this, top: topBoundary);
    boundaries.forEach(add);
    final center = screenToWorld(camera.viewport.effectiveSize / 2);
    paddle = Paddle(center - Vector2(0, 20));

    if (player!.whoHasBall == player!.name) {
      player!.xVel = center.x;
      player!.yVel = center.y;
      var impulse = Vector2.zero();
      addBall(center, impulse);
    }
  }

  void removeBall() {
    remove(ball);
  }

  void addBall(Vector2 pos, Vector2 impulse) {
    ball = Ball(pos, impulse);
    add(ball);
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    super.onDragStart(pointerId, info);
    // Only drag if user grabs paddle
    var p = paddle.center;
    var m = info.eventPosition.game;
    if (p.distanceTo(m) <= paddle.radius) dragValid = true;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    if (!dragValid) return false;
    final mouseJointDef = MouseJointDef()
      ..maxForce = 5000 * paddle.body.mass * 10
      ..dampingRatio = 0.1
      ..frequencyHz = 5
      ..target.setFrom(paddle.body.position)
      ..collideConnected = false
      ..bodyA = groundBody
      ..bodyB = paddle.body;
    mouseJoint ??= world.createJoint(mouseJointDef) as MouseJoint;
    mouseJoint?.setTarget(info.eventPosition.game);

    //updateServer();
    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    if (mouseJoint == null) return true;
    world.destroyJoint(mouseJoint!);
    mouseJoint = null;
    paddle.body.applyLinearImpulse(-paddle.body.linearVelocity * 1500);
    dragValid = false;

    //updateServer();
    return false;
  }

  void updateServer() {
    // Update server
    player!.xVel = paddle.body.linearVelocity.x;
    player!.yVel = paddle.body.linearVelocity.y;
    net.client?.write(jsonEncode(player!.toJson()));
  }
}
