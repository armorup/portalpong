// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'package:flame/game.dart';
import 'package:portalpong/data/models/ball_data.dart';
import 'package:portalpong/main.dart';
import 'package:portalpong/network/network.dart';
import 'package:portalpong/presentation/game_objects/animal.dart';
import 'package:portalpong/presentation/game_objects/balls.dart';
import 'package:portalpong/presentation/game_objects/boundaries.dart';
import 'package:portalpong/presentation/game_objects/paddle.dart';
import 'package:portalpong/presentation/game_objects/portal.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:portalpong/presentation/pages/join_screen.dart';
import 'package:portalpong/presentation/pages/login_screen.dart';
import 'package:portalpong/presentation/pages/wait_screen.dart';

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
  late Animal animal;
  late TextComponent scoreText;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    overlays.add('login');
  }

  void startGame() async {
    await setup();
    add(background);
    add(animal);
    add(paddle);
    add(scoreText);
    if (portal != null) {
      add(portal!);
    }
    state = GameState.playing;
    startBallListener();
  }

  /// Listen for ball changes from stream
  void startBallListener() {
    net.client!.ballDataList.stream.listen((ballDataList) {
      for (var ballData in ballDataList) {
        if (ballData.curOwnerId == data.player.id) {
          if (ballData.isEntering) {
            addBall(ballData);
          }
        }
      }
    });
  }

  void updateScore(String text) {
    scoreText.text = text;
  }

  // Setup the game when game starts
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
          .firstWhere((other) => other.id != data.player.id);
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
    animal = Animal(center - Vector2(0, 25));
    addContactCallback(AnimalContactCallback());

    scoreText = TextComponent(text: animal.lives.toString());
    // Add ball to game
    if (data.ballData.curOwnerId == data.player.id) {
      data.ballData.velocity = Vector2.zero();
      Ball ball = Ball(center, ballData: data.ballData);
      balls.add(ball);
      add(ball);
    }
  }

  /// Call when game is over
  void onGameOver() {
    // Some timer delay
    reset();
    overlays.add('join');
  }

  /// reset game
  void reset() async {
    for (var ball in balls) {
      remove(ball);
    }
    balls.clear();
    if (portal != null) {
      remove(portal!);
    }
    remove(animal);
    remove(paddle);
    remove(background);
    await net.client!.cancel();
    await net.server?.cancel();
  }

  /// remove ball
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
    var ball = Ball(pos, ballData: ballData);
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
