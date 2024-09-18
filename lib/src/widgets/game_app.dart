import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../go_getter.dart';
import 'levels_screen.dart';
import 'overlay_screen.dart';
import 'pause_menu.dart';
import 'package:flutter/services.dart';

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
      widget.onLevelCompleted(); // Oznacz poziom jako ukończony
      game.playState = PlayState.levelCompleted; // Przełącz na stan ukończonego poziomu
      game.overlays.add(PlayState.levelCompleted.name); // Pokaż overlay "Level Completed"
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
      print("Wszystkie poziomy ukończone");
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [
              Color(0xffa9d6e5),
              Color(0xfff2e8cf),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Wyświetlanie wyniku i przycisku pauzy
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xffa9d6e5),
                        Color(0xfff2e8cf),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Score: 0", // Możesz tu dynamicznie ustawiać wynik
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
                  ),
                ),
                // Główna część gry
                Expanded(
                  child: GameWidget(
                    game: game,
                    overlayBuilderMap: {
                      PlayState.welcome.name: (context, game) =>
                      const OverlayScreen(
                        title: "GoGetter",
                        subtitle: "WIP",
                      ),
                      PlayState.levelCompleted.name: (context, game) =>
                      const OverlayScreen(
                        title: "Level Completed",
                        subtitle: "Press Space or Enter to proceed",
                      ),
                    },
                    initialActiveOverlays: [PlayState.welcome.name],
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
