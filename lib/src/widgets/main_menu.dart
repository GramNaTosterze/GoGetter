import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:go_getter/src/models/GameServices/game_service.dart';
import 'settings_screen.dart';
import 'levels_screen.dart';
import 'level_selection.dart';
import 'dart:io';


class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final GameService _gameService = GameService();

  @override
  void initState() {
    super.initState();
    FlameAudio.bgm.initialize();
    FlameAudio.audioCache.loadAll([
      'music/background.mp3',
      'effects/start.mp3',
      'effects/win.mp3',
      'effects/rotate.mp3',
      'effects/no_more_moves.mp3'
    ]);

    _authenticatePlayer();
  }

  Future<void> _authenticatePlayer() async {
    if (! await _gameService.signIn()) {
      return;
    }
    setState(() {});

    var levelData = await _gameService.loadGame();
    if (levelData != null) {
      LevelSelectionState.completedLevels = levelData.$1;
      LevelSelectionState.bestScores = levelData.$2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoGetter'),
        backgroundColor: const Color(0xff0096ce),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff204b5e),
              Color(0xff5d97a2),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if(Settings.musicEnabled) {
                    FlameAudio.play('effects/start.mp3', volume: Settings.volume*0.7);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LevelsScreen()),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.white,
                    ),
                    Text(' '),
                    Text('Levels'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    Text(' '),
                    Text('Settings'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  exit(0);
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                    ),
                    Text(' '),
                    Text('Exit'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
