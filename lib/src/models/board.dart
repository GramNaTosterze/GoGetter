import 'package:graphs/graphs.dart';

import '../components/components.dart';
import 'Levels/level.dart';

///Board class
///
/// Made to be used with Graph dart library
class Board {
  Map<String, Set<String>> nodes;
  Map<int, BlockType?> gameBoard = {for (var i = 0; i < 9; i++) i: null};
  Board({required this.nodes});

  Board.from(Board board) : nodes = {} {

    gameBoard = {for (var i = 0; i < 9; i++) i: board.gameBoard[i]};
    //gameBoard = Map.from(gameBoard);


    for (var v in board.nodes.keys) {
      nodes[v] = Set.from(board.nodes[v]!);
    }
  }

  /// Swaps block [block1] and [block2]
  void swap(BlockType block1, BlockType block2) {
    var p1 = blockPos(block1);
    var p2 = blockPos(block2);

    remove(block1);
    remove(block2);

    place(block1, p2);
    place(block2, p1);
  }

  /// adds block to the board
  void place(BlockType blockType, int placeOnBoard) {
    if (placeOnBoard == -1) return;
    gameBoard[placeOnBoard] = blockType;
    for (var direction in Direction.values) {
      String? vertex = _getVertex(
          placeOnBoard /*board blocks get idx when created*/, direction);
      if (vertex != null) {
        _addEdge(vertex, 'b${blockType.id}$direction');
        _addEdge('b${blockType.id}$direction', vertex);
      }
    }
  }

  /// removes base block from board
  void remove(BlockType block) {
    var vertices = block.nodes.keys;
    var placeOnBoard = blockPos(block);
    gameBoard[placeOnBoard] = null;
    for (var v1 in vertices) {
      for (var v2 in Set.from(nodes[v1]!)) {
        if (!vertices.contains(v2)) {
          _removeEdge(v1, v2);
        }
      }
    }
  }

  /// rotates block of given type
  void rotate(BlockType blockType) {
    // create empty subgraph
    Map<String, Set<String>> newSubgraph = {
      for (var v in blockType.nodes.keys) v: {}
    };

    // construct new rotated subgraph
    for (var v1 in blockType.nodes.keys) {
      var nextVertex =
          '${v1.substring(0, 2)}${Direction.fromString(v1[2]).next()}';
      Set<String> nextVertexEdges = {};
      Set<String> nonSubgraphEdges = {};
      for (var v2 in nodes[v1]!) {
        if (blockType.nodes.keys.contains(v2)) {
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
    for (var vertex in blockType.nodes.keys) {
      nodes[vertex] = newSubgraph[vertex]!;
    }
  }

  int blockPos(BlockType block) => gameBoard.keys.firstWhere((p) => gameBoard[p] == block, orElse: () => -1 );

  bool isConnected(String v1, String v2) {
    return _findShortestPath(v1, v2) != null;
  }

  bool _hasDeadEnds() {
    for (var block in gameBoard.entries) {
      if (!_isValidOnBoard(block)) return true;
    }
    return false;
  }

  bool _isValidOnBoard(MapEntry<int, BlockType?> block) {
    if (block.value == null) return true;
    for (var vertex in block.value!.nodes.keys) {
      var vertices = nodes[vertex]!;
      if (vertices.length <= 1) {
        for (var v in vertices) {
          if (block.value!.nodes.keys.contains(v)) continue;
          if ([
            "u1",
            "u2",
            "u3",
            "d1",
            "d2",
            "d3",
            "l1",
            "l2",
            "l3",
            "r1",
            "r2",
            "r3"
          ].contains(v)) continue;

          if (nodes[v]!.length > 1) return false;
        }
      }
    }
    return true;
  }

  /// Return state of current board {win/lose/none}
  ///
  /// win meaning that all conditions are met
  /// lose - current board configuration is invalid
  /// none - incomplete board
  LevelCondition gameState(Level levelConditions) {
    if (_hasDeadEnds()) return LevelCondition.lose;

    for (var i = 0; i < 9; i++) {
      if (gameBoard[i] == null) {
        return LevelCondition.none;
      }
    }

    for (var condition in levelConditions.conditions) {
      if ( isConnected(condition.start, condition.end) ^ condition.shouldConnect ) {
        return LevelCondition.lose;
      }
    }
    return LevelCondition.win;
  }

  /// Returns vertices of surrounding subgraph based on board block index
  String? _getVertex(int idx, Direction dir) {
    String? neighborVertex = _getNeighborVertex(idx, dir);
    if (neighborVertex != null) {
      return neighborVertex;
    }
    String? boardVertex = _getVertexFromBoard(idx, dir);
    if (boardVertex != null) {
      return boardVertex;
    }

    return null;
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
      if (gameBoard[neighborIdx] != null) {
        return 'b${gameBoard[neighborIdx]!.id}${dir.opposite()}';
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

  void _addEdge(String v1, String v2) {
    if (nodes[v1] == null) {
      nodes[v1] = {v2};
    } else {
      nodes[v1]!.add(v2);
    }
    if (nodes[v2] == null) {
      nodes[v2] = {v1};
    } else {
      nodes[v2]!.add(v1);
    }
  }

  void _removeEdge(String v1, String v2) {
    nodes[v1]?.remove(v2);
    nodes[v2]?.remove(v1);
  }

  Iterable<String>? _findShortestPath(String start, String target) {
    return shortestPath(start, target, (node) => (nodes[node]!));
  }

  @override
  String toString() {
    var str = "";
    for (var key in nodes.keys) {
      str += "$key: ";
      str += "${nodes[key]}\n";
    }
    return str;
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
