import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../go_getter.dart';
import '../config.dart';
import 'overlay_screen.dart';
import 'pause_menu.dart'; // Import PauseMenu

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final GoGetter game;

  @override
  void initState() {
    super.initState();
    game = GoGetter();
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
    Navigator.of(context).pop(); // Zamknij okno pauzy
  }

  void _restartGame() {
    Navigator.of(context).pop(); // Zamknij okno pauzy
    // Wywołanie metody reset w grze
    //game.reset();
  }

  void _exitGame() {
    Navigator.of(context).pop(); // Zamknij okno pauzy
    // Dodaj logikę wychodzenia z gry tutaj
    Navigator.of(context).pushReplacementNamed('/'); // Przykład: powrót do menu głównego
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
            child: Center(
              child: Column(
                children: [
                  // add score
                  Expanded(
                    child: Stack(
                      children: [
                        FittedBox(
                          child: SizedBox(
                            width: gameWidth,
                            height: gameHeight,
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
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft, // Ustawienie przycisku w lewym górnym rogu
                          child: IconButton(
                            icon: const Icon(Icons.pause),
                            onPressed: _showPauseMenu,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
