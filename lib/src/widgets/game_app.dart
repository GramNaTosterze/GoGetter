import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../go_getter.dart';
import 'overlay_screen.dart';
import 'pause_menu.dart';

class GameApp extends StatefulWidget {
  final List<Map<String, String>> levelConditions;
  final VoidCallback onLevelCompleted;

  const GameApp({
    super.key,
    required this.levelConditions,
    required this.onLevelCompleted,
  });

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final GoGetter game;

  @override
  void initState() {
    super.initState();
    game = GoGetter();
    game.onLevelCompleted = widget.onLevelCompleted; // Pass the callback
    //game.startGame();
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
    //game.reset();
  }

  void _exitGame() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
                Container(
                  decoration: BoxDecoration(
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
                        Text(
                          "Score: ${0}",
                          style: const TextStyle(
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
                Expanded(
                  child: GameWidget(
                    game: game,
                    overlayBuilderMap: {
                      PlayState.welcome.name: (context, game) =>
                      const OverlayScreen(
                          title: "GoGetter",
                          subtitle: "WIP"
                      ),
                      PlayState.levelCompleted.name: (context, game) =>
                      const OverlayScreen(
                          title: "Level Completed",
                          subtitle: "Go to the next level"
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