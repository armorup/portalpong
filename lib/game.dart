// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'package:flame/game.dart';
import 'package:portalpong/game_objects/balls.dart';
import 'package:portalpong/game_objects/paddle.dart';
import 'package:portalpong/models/player.dart';
import 'package:portalpong/network/network.dart';
import 'package:portalpong/screens/join_screen.dart';
import 'package:portalpong/screens/login_screen.dart';
import 'package:portalpong/screens/wait_screen.dart';
import 'game_objects/boundaries.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';

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
          'game': (context, PortalPongGame game) => JoinScreen(game: game),
        },
      ),
    );
  }
}

/// The game
class PortalPongGame extends Forge2DGame with MultiTouchDragDetector {
  PortalPongGame() : super(gravity: Vector2(0, 0)) {
    othersSub = othersUpdate();
  }

  Player? player;
  late Paddle paddle;
  // Map player name with their paddle
  Map<String, Paddle> otherPlayers = {};
  StreamSubscription? othersSub;

  late Ball ball;
  late SpriteComponent background;
  bool dragValid = false;

  late Body groundBody;
  MouseJoint? mouseJoint;

  StreamSubscription? othersUpdate() {
    if (net.client == null) return null;
    Stream<List<Player>> stream = net.client!.players.stream;
    final center = screenToWorld(camera.viewport.effectiveSize / 2);
    return stream.listen((players) {
      for (var player in players) {
        String name = player.name;
        Paddle paddle = otherPlayers.putIfAbsent(name, () => Paddle(center));
        paddle.body.applyLinearImpulse(player.velocity);
      }
    });
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await setup();
    add(background);
    add(ball);
    add(paddle);

    overlays.add('login');
    // var pos = screenToWorld(Vector2(0, 30));
    // var width = screenToWorld(camera.viewport.effectiveSize).x;
    //add(Portal(position: pos, width: width));
    //addContactCallback(PortalContactCallback());
  }

  Future<void> setup() async {
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
    final bgSprite = await Sprite.load('background.png');
    background = SpriteComponent(sprite: bgSprite);
    groundBody = world.createBody(BodyDef());
    final center = screenToWorld(camera.viewport.effectiveSize / 2);
    ball = Ball(center);
    paddle = Paddle(center);
    // Add others with stream?

    //others.add(Paddle.other(center));
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

///
class Portal extends BodyComponent {
  final Vector2 position;
  final double width;
  final double height;
  final Paint _black = BasicPalette.black.paint();

  late List<Vector2> vertices;
  Portal({required this.position, required this.width, this.height = 3}) {
    vertices = [
      Vector2(0, 0),
      Vector2(width, 0),
      Vector2(width, height),
      Vector2(0, height),
    ];
  }

  @override
  Body createBody() {
    final shape = PolygonShape();
    shape.set(vertices);

    final fixtureDef = FixtureDef(shape)..isSensor = true;

    final bodyDef = BodyDef()
      // To be able to determine object in collisio
      ..userData = this
      ..position = position
      ..type = BodyType.static;

    body = world.createBody(bodyDef)..createFixture(fixtureDef);
    body.applyLinearImpulse(Vector2.random().normalized() * 1000);
    return body;
  }

  @override
  void renderPolygon(Canvas canvas, List<Offset> points) {
    super.renderPolygon(canvas, points);
  }
}

class PortalContactCallback extends ContactCallback<Portal, Ball> {
  @override
  void begin(Portal a, Ball b, Contact contact) {}

  @override
  void end(Portal a, Ball b, Contact contact) {}
}
