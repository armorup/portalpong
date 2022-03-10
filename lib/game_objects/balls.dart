import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide Draggable;
import 'package:flame/palette.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

class Ball extends BodyComponent {
  late Paint originalPaint;
  bool giveNudge = false;
  final double radius;
  final Vector2 _position;
  double _timeSinceNudge = 0.0;
  static const double _minNudgeRest = 2.0;

  final Paint _blue = BasicPalette.blue.paint();
  final Paint _black = BasicPalette.black.paint();

  Ball(this._position, {this.radius = 2}) {
    originalPaint = randomPaint();
    paint = _black;
  }

  Paint randomPaint() => PaintExtension.random(withAlpha: 0.9, base: 100);

  @override
  Body createBody() {
    final shape = CircleShape();
    shape.radius = radius;

    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8
      ..density = 1.0
      ..friction = 0.1;

    final bodyDef = BodyDef()
      // To be able to determine object in collision
      ..userData = this
      ..angularDamping = 0.8
      ..position = _position
      ..type = BodyType.dynamic;

    body = world.createBody(bodyDef)..createFixture(fixtureDef);
    body.applyLinearImpulse(Vector2.random().normalized() * 1000);
    return body;
  }

  @override
  void renderCircle(Canvas canvas, Offset center, double radius) {
    super.renderCircle(canvas, center, radius);
    final lineRotation = Offset(0, radius);
    canvas.drawLine(center, center + lineRotation, _blue);
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

class DraggableBall extends Ball with Draggable {
  DraggableBall(Vector2 position) : super(position, radius: 5) {
    originalPaint = Paint()..color = Colors.amber;
    paint = originalPaint;
  }

  @override
  bool onDragStart(int pointerId, DragStartInfo info) {
    paint = randomPaint();
    return true;
  }

  @override
  bool onDragUpdate(int pointerId, DragUpdateInfo info) {
    final worldDelta = Vector2(1, -1)..multiply(info.delta.game);
    body.applyLinearImpulse(worldDelta * 1000);
    return true;
  }

  @override
  bool onDragEnd(int pointerId, DragEndInfo info) {
    paint = originalPaint;
    return true;
  }
}

class TappableBall extends Ball with Tappable {
  TappableBall(Vector2 position) : super(position) {
    originalPaint = BasicPalette.white.paint();
    paint = originalPaint;
  }

  @override
  bool onTapDown(info) {
    body.applyLinearImpulse(Vector2.random() * 1000);
    paint = randomPaint();
    return false;
  }
}
