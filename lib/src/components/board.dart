import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../go_getter.dart';
import 'block.dart';

class GameBoard extends RectangleComponent with HasGameReference<GoGetter> {
  GameBoard()
      : super(
    paint: Paint()..color = const Color(0xff1c9b09),
  );
  late final List<BoardBlock> blocks;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);

    Vector2 blockSize = size/6;
    Vector2 start = size/2 - blockSize;
    blocks = [for(int i = 0; i < 9; i++)
      BoardBlock(
          position: start + position + Vector2(blockSize.x * (i%3).toDouble(), blockSize.y * (i~/3).toDouble()),
          color: const Color(0xff157005))];

    addAll(blocks);
  }

}