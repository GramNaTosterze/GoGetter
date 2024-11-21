import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/levels_screen.dart';

import 'components/components.dart';
import 'config.dart';

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
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    overlays.clear();
  }

  VoidCallback? onLevelCompleted;
  VoidCallback? onLevelChanged; // Nowa funkcja, aby poinformować o zmianie poziomu

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

    for (var blockType in BlockType.values) {
      world.add(PathComponent(
        blockType,
        position: Vector2(200.0 * blockType.index, 1500.0),
        board: boardComponent,
        levelConditions: currentLevelConditions,
        onLevelCompleted: _handleLevelCompleted,
      ));
    }
  }

  void stopGame() {
    world.remove(boardComponent);
    world.children
        .where((component) => component is PathComponent)
        .toList()
        .forEach(world.remove);
    playState = PlayState.welcome;
  }

  void _handleLevelCompleted() {
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
          onLevelChanged!();  // Informujemy o zmianie poziomu
        }
      } else {
        print("Wszystkie poziomy ukończone");
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (playState == PlayState.levelCompleted &&
        (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.enter)) {
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

