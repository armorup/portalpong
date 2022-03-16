import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/contact_callbacks.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:portalpong/game.dart';
import 'package:portalpong/game_objects/balls.dart';
import 'package:portalpong/main.dart';
import 'package:portalpong/models/player.dart';
import 'package:portalpong/network/network.dart';

/// Game portal
class Portal extends BodyComponent {
  final Player owner; // Who the portal belongs to
  final Vector2 position;
  final double width;
  final double height;
  //final Paint _black = BasicPalette.black.paint();

  late List<Vector2> vertices;
  Portal({
    required this.owner,
    required this.position,
    required this.width,
    this.height = 3,
  }) {
    vertices = [
      Vector2(0, 0),
      Vector2(width, 0),
      Vector2(width, height),
      Vector2(0, height),
    ];
  }

  @override
  Body createBody() {
    final shape = PolygonShape()..set(vertices);
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
  void end(Portal a, Ball b, Contact contact) {
    if (a.owner.name == b.ballData.prevOwner && b.ballData.isEntering) {
      b.ballData.isEntering = false;
      net.client!.ballDataList.update(b.ballData);
      return;
    }
    data.ballData.curOwner = a.owner.name;
    data.ballData.prevOwner = data.player.name;
    data.ballData.velocity = b.body.linearVelocity;
    data.ballData.isEntering = true;

    net.client!.write();
    game.removeBall(b);
  }
}
