import 'package:flutter/foundation.dart';
import 'package:go_getter/src/components/components.dart';

import '../models.dart';

///Solver class
///
/// Determines if current board is solvable
class Solver {
  Board board;
  List<PathComponent> pathBlocks;
  Level levelConditions;

  Solver({
    required this.board,
    required this.pathBlocks,
    required this.levelConditions
  });

  Future<Hint?> hint() async {
    return  (await solve()).$1;
  }

  Future<bool> isSolvable() async {
    return (await solve()).$2;
  }

  Future<(Hint?, bool)> solve() async {
    return compute((msg) => _solve(/*Blocks not placed on the board*/
        pathBlocks.where((pb) => pb.block == null).map((pb) => pb.blockType).toList(),
        Board.from(board)), null);
  }

  Future<(Hint?, bool)> _solve(List<BlockType> notPlaces, Board board) async {
    var boardState = board.gameState(levelConditions);
    if (boardState == LevelCondition.lose || notPlaces.isEmpty) {
      return (null, boardState == LevelCondition.win);
    }

    for (var block in notPlaces) {
      for (var place = 0; place < 9; place++) {
        if (board.gameBoard[place] == null) { // empty blocks on the board

          List<BlockType> remaining = List.from(notPlaces);
          var newBoard = Board.from(board);

          remaining.remove(block);
          newBoard.place(block, place);
          var numOfRotations = 0;
          for (var _ in Direction.values) {
            var isSolved = await _solve(remaining, newBoard);
            if (isSolved.$2) {
              return (Hint(blockType: block, place: place, numOfRotations: numOfRotations), true);
            }
            newBoard.rotate(block);
            numOfRotations++;
          }
          //board.remove(block);
        }
      }
    }
    return (null, false);
  }

}