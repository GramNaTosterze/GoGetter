import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'block.dart';

class PathBlock extends BoardBlock with DragCallbacks, TapCallbacks {
  Vector2 _startPos;
  late PositionComponent pathComponent;
  PathBlock({
    required super.position,
}) : _startPos = position!, super(
    color: const Color(0xff255ac2),
  );

  void returnToStartingPosition() {
    position = _startPos.clone();
  }
  void swap(BoardBlock other) {
    BoardBlock? tmp = block;

    position = other.position.clone();
    block?.block = other;
    block = other.block;

    other.position = _startPos.clone();
    other.block?.block = this;
    other.block = tmp;
  }

  BoardBlock getClosestBoardBlock() {
    PositionComponent closest = activeCollisions.first;
    for(var collision in activeCollisions) {
      if (closest.distance(this) > collision.distance(this)) {
        closest = collision;
      }
    }
    return closest as BoardBlock;
  }
  @override FutureOr<void> onLoad() async {
    super.onLoad();
    hitbox.collisionType = CollisionType.passive;

    // tmp - replace with image
    pathComponent = RectangleComponent(
      position: size/2,
      size: size/3,
      paint: Paint()..color = const Color(0xffd2d213),
    );
    add(pathComponent);
  }

  @override
  void render(Canvas canvas) {
    if (isDragged) {
      paint.color = color.withOpacity(0.75);

    } else {
      paint.color = color.withOpacity(1);
    }
    super.render(canvas);
  }

  @override void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    pathComponent.angle += degrees2Radians * 90;
    priority = 9;
  }

  @override void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    priority = 10;
    _startPos = position.clone();
  }
  @override void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    priority = 0;
    var block = this.block;
    if(isColliding) {
      BoardBlock closest = getClosestBoardBlock();
      if(!closest.isEmpty()) {
        if(closest.block != this) {
          swap(closest.block!);
        } else {
          returnToStartingPosition();
        }
      } else {
        position = closest.position.clone();

        if(block != null) {
          block.block = null;
        }
        closest.block = this;
        this.block = closest;
      }
    } else if (block != null) {
      block.block = null;
      this.block = null;
    }
  }


  @override void onDragUpdate(DragUpdateEvent event) {
    position +=  event.localDelta;
  }
}