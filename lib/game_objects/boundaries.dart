import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:forge2d/forge2d.dart';

List<Wall> createBoundaries(
  Forge2DGame game, {
  bool top = true,
  bool left = true,
  bool bottom = true,
  bool right = true,
}) {
  double offset = 0;
  final topLeft = game.screenToWorld(Vector2.all(offset)); //Vector2.zero();
  final bottomRight = game.screenToWorld(
      game.camera.viewport.effectiveSize - Vector2.all(offset * 2));
  final topRight = Vector2(bottomRight.x, topLeft.y);
  final bottomLeft = Vector2(topLeft.x, bottomRight.y);

  List<Wall> walls = [
    if (top) Wall(topLeft, topRight),
    if (right) Wall(topRight, bottomRight),
    if (bottom) Wall(bottomRight, bottomLeft),
    if (left) Wall(bottomLeft, topLeft),
  ];

  return walls;
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
      ..friction = 0.0;

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
