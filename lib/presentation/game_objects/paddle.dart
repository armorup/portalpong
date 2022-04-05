import 'package:flame/palette.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Draggable;

const int playerGroup = -1;

class Paddle extends BodyComponent {
  final double radius;
  Vector2 position;
  late FixtureDef fixtureDef;
  late CircleShape shape;
  final Paint _blue = BasicPalette.blue.paint();
  final Paint _red = BasicPalette.red.paint();

  Paddle(this.position, {this.radius = 4}) {
    paint = _blue;
    shape = CircleShape()..radius = radius;
    fixtureDef = FixtureDef(shape);
  }

  Paddle.other(this.position, {this.radius = 4}) {
    paint = _red;
    shape = CircleShape()..radius = radius;
    fixtureDef = FixtureDef(shape);
    fixtureDef.isSensor = true;
  }

  @override
  Body createBody() {
    fixtureDef
      ..restitution = 0.5
      ..density = 30.0
      ..filter.groupIndex = playerGroup
      ..friction = 1.0;
    final bodyDef = BodyDef()
      // To be able to determine object in collision
      ..userData = this
      ..angularDamping = 1.0
      ..position = position
      ..type = BodyType.dynamic;
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
