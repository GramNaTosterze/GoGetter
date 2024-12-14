import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_getter/src/widgets/level_selection.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:go_getter/src/widgets/settings_screen.dart';

import '../go_getter.dart';
import '../models/GameServices/game_service.dart';
import '../models/Levels/level.dart';
import 'overlay_screen.dart';
import 'pause_menu.dart';

class GameApp extends StatefulWidget {
  final VoidCallback onLevelCompleted;
  final Level selectedLevel;

  const GameApp({
    super.key,
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
    if(Settings.musicEnabled) {
      FlameAudio.bgm.play('music/background.mp3', volume: Settings.volume*0.7);
    }
    game = GoGetter();

    game.onLevelCompleted = () {
      widget.onLevelCompleted();
      game.playState = PlayState.levelCompleted;
      if (Settings.musicEnabled) {
        FlameAudio.play('effects/win.mp3', volume: Settings.volume);
      }
      game.overlays.add(PlayState.levelCompleted.name);
    };

    game.startGame(widget.selectedLevel);
  }

  @override
  void dispose() {
    FlameAudio.bgm.stop();
    // Gdy widget GameApp jest usuwany, wyczyść referencje w GoGetter
    game.disposeGame();
    super.dispose();
  }

  void _proceedToNextLevel() async {
    await LevelSelectionState.loadNext();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameApp(
          onLevelCompleted: () {
            LevelSelectionState.markLevelAsCompleted(LevelSelectionState.currentLevel!.idx);
          },
          selectedLevel: LevelSelectionState.currentLevel ?? Level(-1, []),
        ),
      ),
    );
  }

  KeyEventResult onKeyEvent(
      KeyEvent event,
      Set<LogicalKeyboardKey> keysPressed,
      ) {
    if (game.playState == PlayState.levelCompleted) {
      if (event.logicalKey == LogicalKeyboardKey.space || event.logicalKey == LogicalKeyboardKey.enter) {
        _proceedToNextLevel();
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
    int bestScore = LevelSelectionState.bestScores[game.currentLevel.idx] ?? 0;
    final GameService gameService = GameService();
    return GestureDetector(
      onTap: () {
        if (game.playState == PlayState.levelCompleted) {
          _proceedToNextLevel();

        }
      },
      child: Scaffold(
        body: Focus(
          // autofocus: true,
          // onKey: (FocusNode node, RawKeyEvent event) {
          //   if (game.playState == PlayState.levelCompleted &&
          //       (event.logicalKey == LogicalKeyboardKey.space ||
          //           event.logicalKey == LogicalKeyboardKey.enter)) {
          //     _proceedToNextLevel();
          //     return KeyEventResult.handled;
          //   }
          //   return KeyEventResult.ignored;
          // },
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.pause),
                                    onPressed: _showPauseMenu,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: Settings.showScore ?
                                      [
                                        Text(
                                          "Best Score: $bestScore",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ValueListenableBuilder<int>(
                                          valueListenable: game.currentScoreNotifier,
                                          builder: (context, value, child) {
                                            return Text(
                                              "Current Score: $value",
                                              style: const TextStyle(fontSize: 18, color: Colors.white),
                                            );
                                          },
                                        ),
                                      ] : [],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            displayCondition(),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Transform.translate(
                        offset: const Offset(0, 0),
                        child: GameWidget(
                          game: game,
                          overlayBuilderMap: {
                            PlayState.levelCompleted.name: (context, game) {
                              final currentScore = (game as GoGetter).currentScore;
                              return Center(
                                child: Container(
                                  width: 300,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xff204b5e),
                                        Color(0xff5d97a2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 8,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Level Completed",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      if (Settings.showScore)
                                      ...[
                                      Text(
                                        "Your Score: $currentScore",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 18, color: Colors.white),
                                      ),
                                      Text(
                                        "Best Score: $bestScore",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 18, color: Colors.white),
                                      ),
                                      ],
                                      const SizedBox(height: 20),
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 15),
                                                backgroundColor: const Color(0xff5d97a2),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  side: const BorderSide(color: Colors.white, width: 2),
                                                ),
                                              ),
                                              onPressed: () {
                                                _proceedToNextLevel();
                                              },
                                              child: const Text("Next Level"),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 15),
                                                backgroundColor: const Color(0xff5d97a2),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  side: const BorderSide(color: Colors.white, width: 2),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Levels"),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 15),
                                                backgroundColor: const Color(0xff5d97a2),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  side: const BorderSide(color: Colors.white, width: 2),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Main Menu"),
                                            ),
                                          ),
                                          if(gameService.isAuthenticated) ...[
                                            const SizedBox(height: 10),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                                  backgroundColor: const Color(0xff5d97a2),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    side: const BorderSide(color: Colors.white, width: 2),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  gameService.showLeaderboard(game.currentLevel.idx);
                                                },
                                                child: const Text("Ranking"),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            "Hint_NoMoreMoves": (context, game) => const OverlayScreen(
                              title: "No valid Moves",
                              subtitle: "Try something different",
                            ),
                            "Hint_btn": (context, game) => ElevatedButton(
                              onPressed: () => (game as GoGetter).boardComponent.requestHint(),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lightbulb,
                                    color: Colors.white,
                                  ),
                                  Text(' '),
                                  Text('Hint'),
                                ],
                              ),
                            ),
                          },
                          initialActiveOverlays: const [],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget displayCondition() {
    try {
      return Image.asset('assets/images/levels/${game.currentLevel.idx}.png', width: 200, height: 160);
    }
    catch (_) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['u1', 'u2', 'u3', 'd1', 'd2', 'd3', 'r1', 'r2', 'r3', 'l1', 'l2', 'l3']
            .map((v) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: game.currentLevel.conditions
                .where((condition) => condition.start == v)
                .map((condition) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/images/board/${condition.start}.png', width: 40, height: 40),
                  Image.asset('assets/images/UI/${
                      condition.shouldConnect ? 'connection' : 'no_connection'
                  }.png', width: 40, height: 40),
                  Image.asset('assets/images/board/${condition.end}.png', width: 40, height: 40),
                ],

              );
            }).toList(),
          );
        }).toList(),
      );
    }
  }
}