import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';

import '../go_getter.dart';

class BlockComponent extends RectangleComponent
    with HasGameReference<GoGetter>, CollisionCallbacks {
  @protected
  final int idx;
  @protected
  final Color color;
  late ShapeHitbox hitbox;
  BlockComponent? block;
  BlockComponent({required this.idx, required super.position, required this.color})
      : super(
          anchor: Anchor.center,
          paint: Paint()..color = color,
        );

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width / 6, game.width / 6);
    hitbox = RectangleHitbox()..renderShape = false;
    add(hitbox);
  }

  bool isEmpty() {
    return block == null;
  }
}
