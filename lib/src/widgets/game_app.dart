import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../go_getter.dart';
import 'levels_screen.dart';
import 'overlay_screen.dart';
import 'pause_menu.dart';

class GameApp extends StatefulWidget {
  final List<Map<String, String>> levelConditions;
  final VoidCallback onLevelCompleted;
  final int selectedLevel;

  const GameApp({
    super.key,
    required this.levelConditions,
    required this.onLevelCompleted,
    required this.selectedLevel,
  });

  @override
  _GameAppState createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final GoGetter game;

  @override
  void initState() {
    super.initState();
    game = GoGetter();

    game.onLevelCompleted = () {
      widget.onLevelCompleted();
      game.playState = PlayState.levelCompleted;
      game.overlays.add(PlayState.levelCompleted.name);
    };

    // Zaktualizowanie stanu przy zmianie poziomu
    game.onLevelChanged = () {
      setState(() {}); // Wywołanie setState, aby odświeżyć UI
    };

    game.startGame(LevelsScreenState.getLevels(), widget.selectedLevel);
  }

  void _proceedToNextLevel() {
    int nextLevel = widget.selectedLevel + 1;
    if (nextLevel < LevelsScreenState.getLevels().length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameApp(
            levelConditions: LevelsScreenState.getLevels()[nextLevel],
            onLevelCompleted: () {
              LevelsScreenState.markLevelAsCompleted(nextLevel);
            },
            selectedLevel: nextLevel,
          ),
        ),
      );
    } else {
      if (kDebugMode) {
        print("Wszystkie poziomy ukończone");
      }
    }
  }

  KeyEventResult onKeyEvent(
      KeyEvent event,
      Set<LogicalKeyboardKey> keysPressed,
      ) {
    if (game.playState == PlayState.levelCompleted) {
      if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.enter) {
        _proceedToNextLevel(); // Przejście do kolejnego poziomu po naciśnięciu klawisza
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _showPauseMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PauseMenu(
          onResume: _resumeGame,
          onRestart: _restartGame,
          onExit: _exitGame,
        );
      },
    );
  }

  void _resumeGame() {
    Navigator.of(context).pop();
  }

  void _restartGame() {
    Navigator.of(context).pop();
    game.reset();
  }

  void _exitGame() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        autofocus: true,
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, 0.35),
              colors: <Color>[
                Color(0xff5d97a2),
                Color(0xff204b5e),
                Color(0xff204b5e),
              ],
              stops: <double>[0.2, 0.5, 0.8],
              radius: 2.0,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Górny panel z wynikiem i pauzą
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Score: 0",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.pause),
                      onPressed: _showPauseMenu,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Warunki ukończenia poziomu:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Warunki poziomu
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (game.currentLevelConditions ?? []).map((condition) {
                    return Row(
                      children: [
                        Image.asset('assets/images/board/${condition['start']}.png', width: 40, height: 40),
                        Image.asset(
                          'assets/images/UI/${
                              bool.tryParse(condition['no_connection'] ?? 'false') ?? true ? 'no_connection' : 'connection'
                          }.png',
                          width: 40,
                          height: 40,
                        ),
                        Image.asset('assets/images/board/${condition['end']}.png', width: 40, height: 40),
                      ],
                    );
                  }).toList(),
                ),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, 100),
                    child: GestureDetector(
                      onTap: () {
                        if (game.playState == PlayState.levelCompleted) {
                          _proceedToNextLevel();
                        }
                      },
                      child: GameWidget(
                        game: game,
                        overlayBuilderMap: {
                          PlayState.levelCompleted.name: (context, game) =>
                          const OverlayScreen(
                            title: "Level Completed",
                            subtitle: "Press Space or Enter to proceed",
                          ),
                          "Hint_NoMoreMoves": (context, game) =>
                          const OverlayScreen(title: "No valid Moves", subtitle: "Try different approach"),
                        },
                        initialActiveOverlays: [],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
