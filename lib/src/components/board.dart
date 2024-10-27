import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../go_getter.dart';
import 'block.dart';

import '../logic/board.dart';

class BoardComponent extends RectangleComponent
    with HasGameReference<GoGetter> {
  BoardComponent()
      : board = Board(nodes: {
          // upper destination
          'u1': {},
          'u2': {},
          'u3': {},

          // down
          'd1': {},
          'd2': {},
          'd3': {},

          // left
          'l1': {},
          'l2': {},
          'l3': {},

          // right
          'r1': {},
          'r2': {},
          'r3': {},
        }),
        super(paint: Paint()..color = Colors.transparent);

  late final List<BlockComponent> blocks;
  Board board;

  @override
  void render(Canvas canvas) {
    // Rysowanie tła z gradientem radialnym
    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    const RadialGradient gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: <Color>[
        Color(0xff878787),
        Color(0xFFaeff80),
        Color(0xff3b7850),
      ],
      stops: <double>[0.25, 0.15, 0.6],
    );

    final Paint paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Rysowanie prostokąta z gradientem od szarego do białego
    Rect centerRect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2),
      width: size.x / 1.6,
      height: size.x / 1.6,
    );

    const LinearGradient rectGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Color(0xff727272), // Szary
        Color(0xffd7d7d7), // Biały
      ],
    );

    final Paint rectPaint = Paint()
      ..shader = rectGradient.createShader(centerRect);
    canvas.drawRect(centerRect, rectPaint);

    super.render(canvas);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);

    add(SpriteComponent(
        sprite: Sprite(await game.images.load('board.png')),
        position: size / 2,
        size: size * 0.8,
        anchor: Anchor.center));

    Vector2 blockSize = size / 6 + Vector2(10, 10);
    Vector2 start = size / 2 - blockSize;
    blocks = [
      for (int i = 0; i < 9; i++)
        BlockComponent(
          idx: i,
          position: start +
              position +
              Vector2(blockSize.x * (i % 3).toDouble(),
                  blockSize.y * (i ~/ 3).toDouble()),
          color: const Color(0xff157005).withOpacity(0.8),
        )
    ];

    addAll(blocks);
  }


  /// Return state of current board {win/lose/none}
  ///
  /// win meaning that all conditions are met
  /// lose - current board configuration is invalid
  /// none - incomplete board
  LevelCondition gameState() {
    if (blocks.where((pb) => pb.block == null).isNotEmpty) { return LevelCondition.none; }
    bool allConditionsMet = true;

    for (var condition in game.currentLevelConditions ?? []) {
      String start = condition['start']!;
      String end = condition['end']!;
      
      if (!board.isConnected(start, end)) {
        allConditionsMet = false;
        break;
      }
    }

    return allConditionsMet ? LevelCondition.win : LevelCondition.lose;
  }

  BoardComponent copy() {
    BoardComponent copy = BoardComponent();
    copy.blocks = List.from(blocks);
    copy.board = board.copy();
    return copy;
  }
}

enum LevelCondition {
  win,
  lose,
  none
}