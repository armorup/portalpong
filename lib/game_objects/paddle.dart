import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'package:flame/palette.dart';

class Paddle extends BodyComponent {
  final double radius;
  Vector2 position;

  final Paint _blue = BasicPalette.blue.paint();
  final Paint _red = BasicPalette.red.paint();

  Paddle(this.position, {this.radius = 4}) {
    paint = _red;
  }

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = radius;

    final fixtureDef = FixtureDef(shape)
      ..restitution = 1.0
      ..density = 1.0
      ..friction = 0.0;

    final bodyDef = BodyDef()
      // To be able to determine object in collision
      ..userData = this
      ..angularDamping = 0.8
      ..position = position
      ..type = BodyType.kinematic;

    body = world.createBody(bodyDef)..createFixture(fixtureDef);
    return body;
  }

  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    super.renderCircle(canvas, center, radius);
    final lineRotation = Offset(0, radius);
    canvas.drawLine(center, center + lineRotation, _blue);
  }
}
