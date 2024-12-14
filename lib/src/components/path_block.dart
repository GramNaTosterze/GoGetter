import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_getter/src/components/components.dart';
import 'package:go_getter/src/widgets/settings_screen.dart';
import 'block.dart';

/// Block that describes the Path.
class PathComponent extends BlockComponent with DragCallbacks, TapCallbacks {
  Vector2 _startPos;
  late PositionComponent sprite;
  final BlockType blockType;

  BoardComponent boardComponent;

  PathComponent(
    this.blockType, {
    required super.position,
    required this.boardComponent,
  })  : _startPos = position!,
        super(
          idx: -1,
          color: const Color(0xffffffff),
        );

  /// Returns block id
  int id() {
    return blockType.id;
  }

  /// Returns closest Block placed on the board
  BlockComponent getClosestBoardBlock() {
    PositionComponent closest = activeCollisions.first;
    for (var collision in activeCollisions) {
      if (closest.distance(this) > collision.distance(this)) {
        closest = collision;
      }
    }
    return closest as BlockComponent;
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Dodaj wierzchołki do tablicy planszy
    for (var node in blockType.nodes.entries) {
      boardComponent.board.nodes[node.key] = Set<String>.from(node.value);
    }

    hitbox.collisionType = CollisionType.passive;

    // Ładowanie sprite'a
    sprite = SpriteComponent(
      sprite: Sprite(game.images.fromCache(blockType.img)),
      position: size / 2,
      size: size,
      anchor: Anchor.center,
    );
    add(sprite);
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

  @override
  void onTapUp(TapUpEvent event) {
    if(Settings.musicEnabled) {
      FlameAudio.play('effects/rotate.mp3', volume: Settings.volume);
    }
    super.onTapUp(event);

    sprite.angle += degrees2Radians * 90;
    priority = 9;
    game.currentScore += 100;
    boardComponent.board.rotate(blockType);
    if (boardComponent.board.gameState(game.currentLevel) ==
        LevelCondition.win) {
      game.handleLevelCompleted();
    }

    if (kDebugMode) {
      debugPrint(boardComponent.board.toString());
      //debugPrint("solvable?: ${game.solver.isSolvable()}");
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    priority = 10;
    _startPos = position.clone();
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    priority = 0;
    place();
    if (boardComponent.board.gameState(game.currentLevel) ==
        LevelCondition.win) {
      game.handleLevelCompleted();
    }


    if (boardComponent.board.gameBoard.values.where((el) => el != null).length >= 5) {
      game.overlays.add('Hint_btn');
    } else {
      game.overlays.remove('Hint_btn');
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    Vector2 tmp = position;
    tmp += event.localDelta;
    if (tmp.x >= size.x/2 &&
         tmp.x + size.x/2 <= game.width &&
         tmp.y >= size.y/2 &&
         tmp.y + size.y/2 <= game.size.y
    ) {
      position = tmp;
    }
  }

  /// moves block to original position
  void _returnToStartingPosition() {
    position = _startPos.clone();
    // no change in graph
  }

  /// Places block on the board
  ///
  /// If there is already block present it swaps their places
  void place() {
    if (isColliding) {
      BlockComponent closest = getClosestBoardBlock();
      if (!closest.isEmpty()) {
        if (closest.block != this) {
          game.currentScore += 100;
          _swap(closest.block!);
        } else {
          _returnToStartingPosition();
        }
      } else {
        game.currentScore += 100;
        move(closest);
      }
    } else if(block != null) {
      block?.block = null;
      boardComponent.board.remove(blockType);
      block = null;
    }
  }

  /// Swaps two blocks on the [boardComponent]
  void _swap(BlockComponent other) {
    BlockComponent? tmp = block;

    position = other.position.clone();
    block?.block = other;
    block = other.block;

    other.position = _startPos.clone();
    other.block?.block = this;
    other.block = tmp;

    // models
    other as PathComponent;
    boardComponent.board.swap(blockType, other.blockType);
  }

  /// Moves block the the position of closest board space
  void move(BlockComponent closest) {
    // gui
    //_pickup();
    var other = block;
    position = closest.position.clone();

    if (other != null) {
      other.block = null;
    }
    closest.block = this;
    block = closest;


    boardComponent.board.remove(blockType);
    boardComponent.board.place(blockType, block!.idx);

    if (kDebugMode) {
      debugPrint(boardComponent.board.toString());
      //debugPrint("solvable?: ${game.solver.isSolvable()}");
    }
  }
}

/// Enum of blocks possible in game.
///
/// Describe ALL blocks(including duplicates),
/// along with the path to the sprite
/// and nodes describing the actual path on the block.
enum BlockType {
  twoArches(id: 1, nodes: {
    'b1u': {'b1l'},
    'b1d': {'b1r'},
    'b1l': {'b1u'},
    'b1r': {'b1d'}
  }),
  arch(id: 2, nodes: {
    'b2u': {'b2r'},
    'b2d': {},
    'b2l': {},
    'b2r': {'b2u'}
  }),
  twoArches2(id: 3, nodes: {
    'b3u': {'b3l'},
    'b3d': {'b3r'},
    'b3l': {'b3u'},
    'b3r': {'b3d'}
  }),
  vPath(id: 4, nodes: {
    'b4u': {},
    'b4d': {'b4l', 'b4r'},
    'b4l': {'b4d'},
    'b4r': {'b4d'}
  }),
  bridge(id: 5, nodes: {
    'b5u': {'b5d'},
    'b5d': {'b5u'},
    'b5l': {'b5r'},
    'b5r': {'b5l'}
  }),
  arch2(id: 6, nodes: {
    'b6u': {},
    'b6d': {'b6l'},
    'b6l': {'b6d'},
    'b6r': {}
  }),
  arch3(id: 7, nodes: {
    'b7u': {'b7l'},
    'b7d': {},
    'b7l': {'b7u'},
    'b7r': {}
  }),
  vPath2(id: 8, nodes: {
    'b8u': {},
    'b8d': {'b8l', 'b8r'},
    'b8l': {'b8d'},
    'b8r': {'b8d'}
  }),
  cross(id: 9, nodes: {
    'b9u': {'b9r', 'b9l', 'b9d'},
    'b9d': {'b9r', 'b9l', 'b9u'},
    'b9l': {'b9r', 'b9d', 'b9u'},
    'b9r': {'b9l', 'b9d', 'b9u'}
  });

  const BlockType({
    required this.id,
    required this.nodes,
  }) : img = 'block_$id.png';

  final int id;

  /// Path representation in a graph
  ///
  /// each block has 4 sides {l, r, u, d}
  /// added to board at start
  ///
  /// Named: b{[id]}{side}
  final Map<String, Set<String>> nodes;

  /// Name of the sprite
  ///
  /// Named: block{[id]}.png
  final String img;
}
