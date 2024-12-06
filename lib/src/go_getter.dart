
import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/components.dart';
import 'config.dart';
import 'models/models.dart';

enum PlayState { welcome, playing, levelCompleted }

class GoGetter extends FlameGame with HasCollisionDetection, KeyboardEvents {
  GoGetter()
      : super(
    camera: CameraComponent.withFixedResolution(
      width: gameWidth,
      height: gameHeight,
    ),
  );

  late BoardComponent boardComponent;
  late PlayState _playState;
  late Solver solver;
  late List<PathComponent> pathBlocks;

  PlayState get playState => _playState;

  set playState(PlayState playState) {
    _playState = playState;
    overlays.clear();
  }

  VoidCallback? onLevelCompleted;
  VoidCallback? onLevelChanged;

  List<Map<String, String>>? currentLevelConditions;
  late int _currentLevel;
  List<List<Map<String, String>>> _levels = [];

  double get width => size.x;

  double get height => size.y;

  void startGame(List<List<Map<String, String>>> levels, int currentLevel) {
    _levels = levels;
    _currentLevel = currentLevel;
    playState = PlayState.playing;

    boardComponent = BoardComponent();
    world.add(boardComponent);

    currentLevelConditions = _levels[_currentLevel];
    // Adding each type of pathblock to the board
    pathBlocks = [
      for (var blockType in BlockType.values)
        PathComponent(
          blockType,
          position: Vector2(150.0 * blockType.index + 200, 1400.0),
          boardComponent: boardComponent,
        )
    ];
    world.addAll(pathBlocks);

    solver = Solver(
        board: boardComponent.board,
        pathBlocks: pathBlocks,
        levelConditions: currentLevelConditions ?? []
    );
  }

  void stopGame() {
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

  void handleLevelCompleted() {
    playState = PlayState.levelCompleted;
    if (onLevelCompleted != null) {
      onLevelCompleted!();
    }
    overlays.add(PlayState.levelCompleted.name);
  }

  void _proceedToNextLevel() {
    if (playState == PlayState.levelCompleted) {
      _currentLevel++;
      if (_currentLevel < _levels.length) {
        stopGame();
        startGame(_levels, _currentLevel);
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
    startGame(_levels, _currentLevel);
  }
}