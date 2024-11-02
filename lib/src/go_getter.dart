
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart'; // Add this import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_getter/src/models/models.dart';

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

  double get width => size.x;
  double get height => size.y;

  late Solver solver;
  late BoardComponent boardComponent;
  late PlayState _playState;
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.welcome:
      case PlayState.levelCompleted:
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.levelCompleted.name);
    }
  }

  VoidCallback? onLevelCompleted;

  List<Map<String, String>>? currentLevelConditions;

  late int _currentLevel; // Zmienna aktualnego poziomu - już nie inicjalizowana na 0
  List<List<Map<String, String>>> _levels = [];

  // startGame teraz ustawia prawidłowy poziom na podstawie przekazanej wartości
  void startGame(List<List<Map<String, String>>> levels, int currentLevel) {
    _levels = levels;
    _currentLevel = currentLevel; // Przypisujemy prawidłowy aktualny poziom
    playState = PlayState.playing;

    boardComponent = BoardComponent();
    world.add(boardComponent);

    currentLevelConditions = _levels[_currentLevel];

    // Adding each type of pathblock to the board
    var pathBlocks = [
      for (var blockType in BlockType.values)
        PathComponent(
          blockType,
          position: Vector2(200.0 * blockType.index, 1500.0),
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
    // Usunięcie komponentów planszy (BoardComponent)
    if (world.contains(boardComponent)) {
      world.remove(boardComponent);
    }

    // Usunięcie wszystkich komponentów typu PathComponent
    world.children
        .whereType<PathComponent>()
        .toList()
        .forEach(world.remove);

    // Reset stanu gry
    playState = PlayState.welcome;
  }


  void handleLevelCompleted() {
    playState = PlayState.levelCompleted;
    if (onLevelCompleted != null) {
      onLevelCompleted!(); // Wywołanie callbacka, jeśli jest ustawiony
    }
    overlays.add(PlayState.levelCompleted.name); // Pokaż overlay informujący o ukończeniu poziomu
  }

  void _proceedToNextLevel() {
    // Sprawdź, czy gra jest w stanie ukończenia poziomu
    if (playState == PlayState.levelCompleted) {
      _currentLevel++; // Zwiększ aktualny poziom

      if (_currentLevel < _levels.length) {
        // Usunięcie komponentów poprzedniego poziomu
        stopGame();
        // Uruchomienie nowego poziomu
        startGame(_levels, _currentLevel);
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
  KeyEventResult onKeyEvent(
      KeyEvent event,
      Set<LogicalKeyboardKey> keysPressed,
      ) {
    if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.enter) {
      _proceedToNextLevel();
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
    // Reset gry do pierwszego poziomu
    //world.children.where((component) => component is PathComponent).forEach(world.remove);
    stopGame();
    startGame(_levels, _currentLevel);
  }
}
