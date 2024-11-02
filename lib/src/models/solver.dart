import 'package:go_getter/src/components/components.dart';

import 'board.dart';

///Solver class
///
/// Determines if current board is solvable
class Solver {
  Board board;
  List<PathComponent> pathBlocks;
  List<Map<String, String>> levelConditions;

  Solver({
    required this.board,
    required this.pathBlocks,
    required this.levelConditions
  });

  BlockType? hint() {
    return solve().$1;
  }

  bool isSolvable() {
    return solve().$2;
  }

  (BlockType?, bool) solve() {
    return _solve(/*Blocks not placed on the board*/
        pathBlocks.where((pb) => pb.block == null).map((pb) => pb.blockType).toList(),
        board.copy());
  }

  (BlockType?, bool) _solve(List<BlockType> notPlaces, Board board) {
     var boardState = board.gameState(levelConditions);
    if (boardState == LevelCondition.lose || notPlaces.isEmpty) {
      return (null, boardState == LevelCondition.win);
    }

    for (var block in notPlaces) {
      for (var place in board.gameBoard.keys) {
        if (board.gameBoard[place] == null) { // empty blocks on the board

          List<BlockType> remaining = List.from(notPlaces);
          remaining.remove(block);
          board.place(block, place);
          for (var _ in Direction.values) {
            if (_solve(remaining, board.copy()).$2) { return (block, true); }
            board.rotate(block);
          }
        }
      }

    }
    return (null, false);
  }

}