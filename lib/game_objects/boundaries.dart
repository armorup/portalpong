import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/rendering.dart';
import 'package:forge2d/forge2d.dart';

import 'package:flutter/material.dart' hide Draggable;

List<Wall> createBoundaries(Forge2DGame game) {
  double offset = 10;
  final topLeft = game.screenToWorld(Vector2.all(offset)); //Vector2.zero();
  final bottomRight = game.screenToWorld(
      game.camera.viewport.effectiveSize - Vector2.all(offset * 2));
  final topRight = Vector2(bottomRight.x, topLeft.y);
  final bottomLeft = Vector2(topLeft.x, bottomRight.y);

  return [
    Wall(topLeft, topRight),
    Wall(topRight, bottomRight),
    Wall(bottomRight, bottomLeft),
    Wall(bottomLeft, topLeft),
  ];
}

class Wall extends BodyComponent {
  final Vector2 start;
  final Vector2 end;

  Wall(this.start, this.end);

  @override
  Body createBody() {
    final shape = EdgeShape()..set(start, end);

    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.0
      ..friction = 0.3;

    final bodyDef = BodyDef()
      ..userData = this // To be able to determine object in collision
      ..position = Vector2.zero()
      ..type = BodyType.static;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Ground extends BodyComponent {
  final Vector2 worldCenter;

  Ground(this.worldCenter);

  @override
  Body createBody() {
    final shape = PolygonShape();
    shape.setAsBoxXY(20.0, 0.4);
    final bodyDef = BodyDef();
    bodyDef.position.setFrom(worldCenter);
    final ground = world.createBody(bodyDef);
    ground.createFixtureFromShape(shape);

    shape.setAsBox(0.4, 20.0, Vector2(-10.0, 0.0), 0.0);
    ground.createFixtureFromShape(shape);
    shape.setAsBox(0.4, 20.0, Vector2(10.0, 0.0), 0.0);
    ground.createFixtureFromShape(shape);
    return ground;
  }
}
