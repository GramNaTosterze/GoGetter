import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:go_getter/src/widgets/settings_screen.dart';

import '../models/models.dart';

import '../go_getter.dart';
import 'block.dart';

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

    Vector2 blockSize = size / 6 + Vector2(10, 10);
    Vector2 start = size / 2 - blockSize + Vector2(0, blockSize.y);

    add(SpriteComponent(
        sprite: Sprite(game.images.fromCache('board.png')),
        position: size / 2 + Vector2(0, blockSize.y),
        size: size * 1.07,
        anchor: Anchor.center));


    addObjectSprites(start, blockSize);

    blocks = [
      for (int i = 0; i < 9; i++)
        BlockComponent(
          idx: i,
          position: start +
              position +
              Vector2(blockSize.x * (i % 3).toDouble(),
                  blockSize.y * (i ~/ 3).toDouble()),
          color: const Color(0xff157005).withOpacity(0),
        )
    ];

    addAll(blocks);
}

  Future requestHint() async {
    var hint = await game.solver.hint();
    game.currentScoreNotifier.value += 300;
    if (hint == null) {
      FlameAudio.play('effects/no_more_moves.mp3', volume: Settings.volume);
      game.overlays.add("Hint_NoMoreMoves");
      Future.delayed(const Duration(seconds: 3),
              () => game.overlays.remove("Hint_NoMoreMoves"));
      return;
    }
    var ghostBlock = SpriteComponent(
      sprite: Sprite(game.images.fromCache(hint.blockType.img)),
      position: blocks[hint.place].position,
      size: blocks[hint.place].size,
      anchor: Anchor.center,
    );
    add(ghostBlock);
    ghostBlock.opacity = 0.5;
    var currentBlockAngle = game.pathBlocks.where((b) => b.blockType.id == hint.blockType.id).first.sprite.angle;
    ghostBlock.angle = degrees2Radians * 90 * hint.numOfRotations;
    ghostBlock.angle += currentBlockAngle;
    Future.delayed(const Duration(seconds: 5),
            () => remove(ghostBlock));
  }

  Future addObjectSprites(Vector2 start, Vector2 blockSize) async {
    for (var i = 0; i < 3; i++) {
      add(SpriteComponent(
          sprite: Sprite(game.images.fromCache('board/u${i+1}.png')),
          position: start - Vector2(0, blockSize.y * 1.25) +
              Vector2(blockSize.x * i, 0),
          size: blockSize,
          anchor: Anchor.center
      ));

      for (var i = 0; i < 3; i++) {
        add(SpriteComponent(
            sprite: Sprite(game.images.fromCache('board/d${i+1}.png')),
            position: start + Vector2(0, blockSize.y * 3.25) +
                Vector2(blockSize.x * i, 0),
            size: blockSize,
            anchor: Anchor.center
        ));
      }

      for (var i = 0; i < 3; i++) {
        add(SpriteComponent(
            sprite: Sprite(game.images.fromCache('board/l${i+1}.png')),
            position: start - Vector2(blockSize.x * 1.25, 0) +
                Vector2(0, blockSize.y * i),
            size: blockSize,
            anchor: Anchor.center
        ));
      }

      for (var i = 0; i < 3; i++) {
        add(SpriteComponent(
            sprite: Sprite(game.images.fromCache('board/r${i+1}.png')),
            position: start + Vector2(blockSize.x * 3.25, 0) +
                Vector2(0, blockSize.y * i),
            size: blockSize,
            anchor: Anchor.center
        ));
      }
    }



  }
}

enum LevelCondition {
  win,
  lose,
  none
}