import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'package:flame/palette.dart';
import 'package:portalpong/game.dart';
import 'package:portalpong/game_objects/balls.dart';
import 'package:portalpong/game_objects/paddle.dart';

class Animal extends BodyComponent {
  int lives;
  late Paint originalPaint;
  bool giveNudge = false;
  final double radius;
  final Vector2 _position;
  double _timeSinceNudge = 0.0;
  static const double _minNudgeRest = 2.0;

  final Paint _magenta = BasicPalette.magenta.paint();

  Animal(this._position, {this.radius = 5, this.lives = 3}) {
    originalPaint = randomPaint();
    paint = _magenta;
  }

  Paint randomPaint() => PaintExtension.random(withAlpha: 0.9, base: 100);

  /// Called when this animal has been hit by ball
  void onHit() {
    lives--;
    var ref = (gameRef as PortalPongGame);
    ref.scoreText.text = lives.toString();
    if (lives <= 0) {
      ref.onGameOver();
    }
  }

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = radius;

    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8
      ..density = 5.0
      ..filter.groupIndex = playerGroup
      ..friction = 0.1;

    final bodyDef = BodyDef()
      // To be able to determine object in collision
      ..userData = this
      ..angularDamping = 0.8
      ..position = _position
      ..type = BodyType.dynamic;

    body = world.createBody(bodyDef)..createFixture(fixtureDef);
    return body;
  }

  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    super.renderCircle(canvas, center, radius);
    final lineRotation = Offset(0, radius);
    canvas.drawLine(center, center + lineRotation, _magenta);
  }

  @override
  @mustCallSuper
  void update(double dt) {
    _timeSinceNudge += dt;
    if (giveNudge) {
      giveNudge = false;
      if (_timeSinceNudge > _minNudgeRest) {
        body.applyLinearImpulse(Vector2(0, 1000));
        _timeSinceNudge = 0.0;
      }
    }
  }
}

/// Lose a life when ball hits the animal
class AnimalContactCallback extends ContactCallback<Animal, Ball> {
  @override
  void begin(Animal a, Ball b, Contact contact) {}

  @override
  void end(Animal a, Ball b, Contact contact) {
    a.onHit();
    print(a.lives);
  }
}
