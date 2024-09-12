import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/components.dart';
import 'config.dart';

enum PlayState { welcome, playing, levelCompleted }

class GoGetter extends FlameGame with HasCollisionDetection {
  GoGetter()
      : super(
    camera: CameraComponent.withFixedResolution(
      width: gameWidth,
      height: gameHeight,
    ),
  );

  double get width => size.x;
  double get height => size.y;

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

  // Add this property
  VoidCallback? onLevelCompleted;

  void startGame() {
    playState = PlayState.playing;

    boardComponent = BoardComponent();
    world.add(boardComponent);

    for (var blockType in BlockType.values) {
      world.add(PathComponent(
        blockType,
        position: Vector2(200.0 * blockType.index, 1500.0),
        board: boardComponent,
        levelConditions: [
          // Example conditions, adjust as needed
          {'start': 'u3', 'end': 'r1'},
          {'start': 'r3', 'end': 'd3'},
        ],
        onLevelCompleted: _handleLevelCompleted, // Use the local handler
      ));
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    playState = PlayState.welcome;
    startGame();
  }

  void _handleLevelCompleted() {
    playState = PlayState.levelCompleted;
    if (onLevelCompleted != null) {
      onLevelCompleted!(); // Call the callback if it is set
    }
    overlays.add(PlayState.levelCompleted.name); // Add overlay to show completion message
  }

  @override
  Color backgroundColor() => Colors.transparent;

}
