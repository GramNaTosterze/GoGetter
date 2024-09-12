import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_getter/src/components/components.dart';
import 'block.dart';

/// Block that describes the Path.
class PathComponent extends BlockComponent with DragCallbacks, TapCallbacks {
  Vector2 _startPos;
  late PositionComponent sprite;
  final BlockType _blockType;

  final BoardComponent board;
  final List<Map<String, String>> levelConditions;
  final VoidCallback onLevelCompleted;

  PathComponent(
      this._blockType, {
        required super.position,
        required this.levelConditions,  // Warunki poziomu
        required this.board,            // Plansza
        required this.onLevelCompleted, // Callback na ukończenie poziomu
      }) : _startPos = position!,
        super(
        idx: -1,
        color: const Color(0xffffffff),
      );

  /// Returns block id
  int id() {
    return _blockType.id;
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
    for (var node in _blockType.nodes.entries) {
      game.boardComponent.board.nodes[node.key] = Set<String>.from(node.value);
    }

    hitbox.collisionType = CollisionType.passive;

    // Ładowanie sprite'a
    sprite = SpriteComponent(
      sprite: Sprite(await game.images.load(_blockType.img)),
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
    super.onTapUp(event);
    sprite.angle += degrees2Radians * 90;
    priority = 9;
    _rotate();
    _checkLevelConditions();
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
    _place();
    _checkLevelConditions();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }

  void _createConnections() {
    for (var direction in Direction.values) {
      Set<String> vertices = game.boardComponent.getVertices(
          block!.idx /*board blocks get idx when created*/, direction);
      for (var vertex in vertices) {
        game.boardComponent.board
            .addEdge(vertex, 'b${_blockType.id}$direction');
        game.boardComponent.board
            .addEdge('b${_blockType.id}$direction', vertex);
      }
    }
  }

  void _removeConnections() {
    for (var v1 in _blockType.nodes.keys) {
      for (var v2 in Set.from(game.boardComponent.board.nodes[v1]!)) {
        if (!_blockType.nodes.keys.contains(v2)) {
          game.boardComponent.board.removeEdge(v1, v2);
        }
      }
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
  void _place() {
    var block = this.block;
    if (isColliding) {
      BlockComponent closest = getClosestBoardBlock();
      if (!closest.isEmpty()) {
        if (closest.block != this) {
          _swap(closest.block!);
        } else {
          _returnToStartingPosition();
        }
      } else {
        _move(closest);
      }
    } else if (block != null) {
      block.block = null;
      this.block = null;
      _removeConnections();
    }
  }

  /// Swaps two blocks on the [board]
  void _swap(BlockComponent other) {
    BlockComponent? tmp = block;

    position = other.position.clone();
    block?.block = other;
    block = other.block;

    other.position = _startPos.clone();
    other.block?.block = this;
    other.block = tmp;

    // logic
    other as PathComponent;
    _removeConnections();
    other._removeConnections();
    _createConnections();
    other._createConnections();
  }

  // Sprawdzanie warunków poziomu
  void _checkLevelConditions() {
    bool allConditionsMet = true;

    for (var condition in levelConditions) {
      String start = condition['start']!;
      String end = condition['end']!;

      // Sprawdzamy, czy dwa wierzchołki są połączone na planszy
      if (!board.isConnected(start, end)) {
        allConditionsMet = false;
        break;
      }
    }

    // Jeśli wszystkie warunki spełnione, wywołujemy callback
    if (allConditionsMet) {
      onLevelCompleted();
    }
  }

  /// Moves block the the position of closest board space
  void _move(BlockComponent closest) {
    // gui
    var other = block;
    position = closest.position.clone();

    if (other != null) {
      other.block = null;
    }
    closest.block = this;
    block = closest;

    _createConnections();

    if (kDebugMode) {
      debugPrint(game.boardComponent.board.toString());
    }
  }

  // rotates this block
  void _rotate() {
    // create empty subgraph
    Map<String, Set<String>> newSubgraph = {
      for (var v in _blockType.nodes.keys) v: {}
    };

    // construct new rotated subgraph
    for (var v1 in _blockType.nodes.keys) {
      var nextVertex =
          '${v1.substring(0, 2)}${Direction.fromString(v1[2]).next()}';
      Set<String> nextVertexEdges = {};
      Set<String> nonSubgraphEdges = {};
      for (var v2 in game.boardComponent.board.nodes[v1]!) {
        if (_blockType.nodes.keys.contains(v2)) {
          nextVertexEdges.add(
              '${v2.substring(0, 2)}${Direction.fromString(v2[2]).next()}');
        } else {
          nonSubgraphEdges.add(v2);
        }
      }

      newSubgraph[nextVertex]!.addAll(nextVertexEdges);
      newSubgraph[v1]!.addAll(nonSubgraphEdges);
    }

    // update in a board graph
    for (var vertex in _blockType.nodes.keys) {
      game.boardComponent.board.nodes[vertex] = newSubgraph[vertex]!;
    }

    if (kDebugMode) {
      debugPrint(game.boardComponent.board.toString());
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
  }) : img = 'block$id.png';

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
