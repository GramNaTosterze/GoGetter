import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'components/components.dart';
import 'config.dart';

enum PlayState {welcome, playing, levelCompleted}

class GoGetter extends FlameGame
    with HasCollisionDetection {
  GoGetter()
    : super(
      camera: CameraComponent.withFixedResolution(
        width: gameWidth,
        height: gameHeight,
      ),
    );

  double get width => size.x;
  double get height => size.y;

  late PlayState _playState;
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    switch(playState) {
      case PlayState.welcome:
      case PlayState.levelCompleted:
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.levelCompleted.name);
    }
  }

  void startGame() {
    playState = PlayState.playing;


    world.add(GameBoard());

    for(int i = 0; i < 9; i++) {
      world.add(PathBlock(i+1, //blockType
        position: Vector2(200.0*i, 1500.0),
      ));
    }
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    playState = PlayState.welcome;
    startGame();
  }

  @override Color backgroundColor() => const Color(0xfff2e8cf);
}