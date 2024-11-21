import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:go_getter/src/components/components.dart';

import '../go_getter.dart';
import 'block.dart';

import '../graph.dart';

class BoardComponent extends RectangleComponent
    with HasGameReference<GoGetter> {
  BoardComponent()
      : board = Graph(nodes: {
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
  Graph board;

  @override
  void render(Canvas canvas) {
    // Rysowanie tła z gradientem radialnym
    Rect rect = Rect.fromLTWH(0, 0, size.x, size.y);
    // const RadialGradient gradient = RadialGradient(
    //   center: Alignment.center,
    //   radius: 1.0,
    //   colors: <Color>[
    //     Color(0xff878787),
    //     Color(0xFFaeff80),
    //     Color(0xff3b7850),
    //   ],
    //   stops: <double>[0.25, 0.15, 0.6],
    // );
    //
    // final Paint paint = Paint()..shader = gradient.createShader(rect);
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

    // Rysowanie dzieci (BoardBlock)
    super.render(canvas);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);

    add(SpriteComponent(
        sprite: Sprite(await game.images.load('plansza.bmp')),
        position: size / 2,
        size: size * 0.61,
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
          color: const Color(0xff157005).withOpacity(0),
        )
    ];

    addAll(blocks);
  }

  bool isConnected(String v1, String v2) {
    return board.findShortestPath(v1, v2) != null;
  }

  /// Returns vertices of surrounding subgraph based on board block index
  Set<String> getVertices(int idx, Direction dir) {
    Set<String> vertices = {};
    String? neighborVertex = _getNeighborVertex(idx, dir);
    String? boardVertex = _getVertexFromBoard(idx, dir);

    if (neighborVertex != null) {
      vertices.add(neighborVertex);
    }
    if (boardVertex != null) {
      vertices.add(boardVertex);
    }

    return vertices;
  }

  String? _getNeighborVertex(int idx, Direction dir) {
    int neighborIdx;
    switch (dir) {
      case Direction.left:
        neighborIdx = idx % 3 == 0 ? -1 : idx - 1;
      case Direction.right:
        neighborIdx = idx % 3 == 2 ? -1 : idx + 1;
      case Direction.up:
        neighborIdx = idx - 3;
      case Direction.down:
        neighborIdx = idx + 3;
    }
    if (neighborIdx >= 0 && neighborIdx < 9) {
      if (blocks[neighborIdx].block != null) {
        return 'b${(blocks[neighborIdx].block as PathComponent).id()}${dir.opposite()}';
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  /// Returns vertices on the edge of the board
  /// that correspond to given place on the board
  String? _getVertexFromBoard(int idx, Direction dir) {
    switch (dir) {
      case Direction.left:
        return _getVertexFromBoardLeft(idx);
      case Direction.right:
        return _getVertexFromBoardRight(idx);
      case Direction.up:
        return _getVertexFromBoardUp(idx);
      case Direction.down:
        return _getVertexFromBoardDown(idx);
    }
  }

  String? _getVertexFromBoardLeft(int idx) {
    switch (idx) {
      case 0:
        return 'l1';
      case 3:
        return 'l2';
      case 6:
        return 'l3';
      case _:
        return null;
    }
  }

  String? _getVertexFromBoardRight(int idx) {
    switch (idx) {
      case 2:
        return 'r1';
      case 5:
        return 'r2';
      case 8:
        return 'r3';
      case _:
        return null;
    }
  }

  String? _getVertexFromBoardUp(int idx) {
    switch (idx) {
      case 0:
        return 'u1';
      case 1:
        return 'u2';
      case 2:
        return 'u3';
      case _:
        return null;
    }
  }

  String? _getVertexFromBoardDown(int idx) {
    switch (idx) {
      case 6:
        return 'd1';
      case 7:
        return 'd2';
      case 8:
        return 'd3';
      case _:
        return null;
    }
  }
}

enum Direction {
  up,
  right,
  down,
  left;

  static Direction fromString(String direction) {
    switch (direction) {
      case 'l':
        return Direction.left;
      case 'r':
        return Direction.right;
      case 'u':
        return Direction.up;
      case 'd':
        return Direction.down;
      case _:
        return Direction.left;
    }
  }

  Direction opposite() {
    switch (this) {
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
    }
  }

  Direction next() {
    switch (this) {
      case Direction.left:
        return Direction.up;
      case Direction.right:
        return Direction.down;
      case Direction.up:
        return Direction.right;
      case Direction.down:
        return Direction.left;
    }
  }

  @override
  String toString() {
    switch (this) {
      case Direction.left:
        return 'l';
      case Direction.right:
        return 'r';
      case Direction.up:
        return 'u';
      case Direction.down:
        return 'd';
    }
  }
}
