
import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_getter/src/models/GameServices/game_service.dart';
import 'package:go_getter/src/widgets/level_selection.dart';
import 'components/components.dart';
import 'config.dart';
import 'models/models.dart';

import 'dart:async' as dart_async;



enum PlayState { welcome, playing, levelCompleted }

class GoGetter extends FlameGame with HasCollisionDetection, KeyboardEvents {
  GoGetter()
      : super(
    camera: CameraComponent.withFixedResolution(
      width: gameWidth,
      height: gameHeight * 1.4,
    ),
  );

  late BoardComponent boardComponent;
  late PlayState _playState;
  late Solver solver;
  late List<PathComponent> pathBlocks;
  int currentScore = 0;
  dart_async.Timer? timer;


  PlayState get playState => _playState;

  set playState(PlayState playState) {
    _playState = playState;
    overlays.clear();
  }

  VoidCallback? onLevelCompleted;
  VoidCallback? onLevelChanged;

  late Level currentLevel;

  double get width => size.x;

  double get height => size.y /1.4;

  void startGame(Level currentLevel) {
    this.currentLevel = currentLevel;
    playState = PlayState.playing;

    boardComponent = BoardComponent();
    world.add(boardComponent);
    // Adding each type of pathblock to the board
    pathBlocks = [
      for (var blockType in BlockType.values)
        PathComponent(
          blockType,
          position: Vector2(150.0 * blockType.index + 200, 1750.0) + Vector2(0, 250),
          boardComponent: boardComponent,
        )
    ];
    world.addAll(pathBlocks);

    solver = Solver(pathBlocks: pathBlocks,

        board: boardComponent.board,
        levelConditions: currentLevel
    );
    currentScore = 0;
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timer = dart_async.Timer.periodic(const Duration(seconds: 1), (timer) {
      currentScore += 1;
      if (onLevelChanged != null) {
        onLevelChanged!();
      }
    });

  }



  void stopTimer() {
    timer?.cancel();
  }

  void disposeGame() {
    stopTimer();
    onLevelChanged = null;
    onLevelCompleted = null;
  }


  void stopGame() {
    stopTimer();
    world.remove(boardComponent);
    // Usunięcie komponentów planszy (BoardComponent)
    if (world.contains(boardComponent)) {
      world.remove(boardComponent);
    }

    // Usunięcie wszystkich komponentów typu PathComponent
    world.children
        .whereType<PathComponent>()
        .toList()
        .forEach(world.remove);
    playState = PlayState.welcome;
  }

  void handleLevelCompleted() async {
    playState = PlayState.levelCompleted;
    stopTimer();
    if (LevelSelectionState.bestScores[currentLevel.idx] == null ||
        currentScore < LevelSelectionState.bestScores[currentLevel.idx]!) {
      LevelSelectionState.bestScores[currentLevel.idx] = currentScore;

    }

    await LevelSelectionState.markLevelAsCompleted(currentLevel.idx);
    final GameService gameService = GameService();
    //await gameService.submitScore(currentLevel.idx, LevelSelectionState.bestScores[currentLevel.idx]!);
    await gameService.submitScore(currentLevel.idx, currentScore);

    await gameService.showLeaderboard(currentLevel.idx);

    if (onLevelCompleted != null) {
      onLevelCompleted!();
    }
    overlays.add(PlayState.levelCompleted.name);
  }

  Future _proceedToNextLevel() async {
    if (playState == PlayState.levelCompleted) {
      if (LevelSelectionState.currentLevel != null) {
        stopGame();

        await LevelSelectionState.loadNext();
        currentLevel = LevelSelectionState.currentLevel!;

        startGame(currentLevel);
        if (onLevelChanged != null) {
          onLevelChanged!();
        }
      } else {
        if (kDebugMode) {
          print("Wszystkie poziomy ukończone");
        }
      }
    } else {
      if (kDebugMode) {
        print("Poziom jeszcze nie został ukończony");
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event,
      Set<LogicalKeyboardKey> keysPressed) {
    if (playState == PlayState.levelCompleted &&
        (event.logicalKey != LogicalKeyboardKey.control)) {
      _proceedToNextLevel();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    playState = PlayState.welcome;
  }

  @override
  Color backgroundColor() => Colors.transparent;

  void reset() {
    stopGame();
    startGame(currentLevel);
  }
}