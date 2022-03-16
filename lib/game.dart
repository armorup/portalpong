// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'package:flame/game.dart';
import 'package:portalpong/game_objects/balls.dart';
import 'package:portalpong/game_objects/paddle.dart';
import 'package:portalpong/game_objects/portal.dart';
import 'package:portalpong/main.dart';
import 'package:portalpong/models/ball_data.dart';
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

  late Paddle paddle;
  Portal? portal;
  GameState state = GameState.joining;
  late SpriteComponent background;
  bool dragValid = false;
  late Body groundBody;
  MouseJoint? mouseJoint;
  List<Ball> balls = [];

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
    startBallListener();
  }

  void startBallListener() {
    var sub = net.client!.ballDataList.stream.listen((ballDataList) {
      for (var ballData in ballDataList) {
        if (ballData.curOwner == data.player.name) {
          if (ballData.isEntering) {
            addBall(ballData);
          }
        }
      }
    });
  }

  Future<void> setup() async {
    // Background
    final bgSprite = await Sprite.load('background.png');
    background = SpriteComponent(sprite: bgSprite);
    groundBody = world.createBody(BodyDef());

    // If other player exists, add a portal
    bool topBoundary = true;
    var players = net.client!.playersList.list;
    if (players.length > 1) {
      topBoundary = false;
      var portalOwner = net.client!.playersList.list
          .firstWhere((other) => other.name != data.player.name);
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
    final center = camera.screenToWorld(camera.viewport.effectiveSize / 2);
    paddle = Paddle(center - Vector2(0, 20));

    // Add ball to game
    if (data.ballData.curOwner == data.player.name) {
      data.ballData.xVel = 0;
      data.ballData.yVel = 0;
      Ball ball = Ball(center, Vector2.zero(), ballData: data.ballData);
      balls.add(ball);
      add(ball);
    }
  }

  /// remove ball associated with this data
  void removeBall(Ball ball) {
    balls.remove(ball); // remove from list
    remove(ball); // remove from game
  }

  /// Called when ball enters player's screen from portal
  void addBall(BallData ballData) {
    //var portalPos = camera.worldToScreen(portal!.position);
    var x = camera.viewport.effectiveSize.x / 2;
    //portalPos.x + portal!.width * (1 - posFromStart);
    var pos = camera.screenToWorld(Vector2(x, 0));
    var impulse = -ballData.velocity;
    var ball = Ball(pos, impulse, ballData: ballData);
    balls.add(ball);
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

    return false;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    if (mouseJoint == null) return true;
    world.destroyJoint(mouseJoint!);
    mouseJoint = null;
    paddle.body.applyLinearImpulse(-paddle.body.linearVelocity * 1500);
    dragValid = false;

    return false;
  }
}
