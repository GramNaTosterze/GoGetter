import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'levels_screen.dart';
import 'level_selection.dart';
import '../../play_games_service.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';


class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  bool _isAuthenticated = false;
  String? _playerId;

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
    // Sprawdź, czy użytkownik jest zalogowany
    bool isAuthenticated = await PlayGamesService.isAuthenticated();
    if (isAuthenticated) {
      // Pobierz Player ID
      String? playerId = await PlayGamesService.getPlayerId();
      setState(() {
        _isAuthenticated = true;
        _playerId = playerId;
      });
    } else {
      bool signedIn = await PlayGamesService.signIn();
      if (signedIn) {
        String? playerId = await PlayGamesService.getPlayerId();
        setState(() {
          _isAuthenticated = true;
          _playerId = playerId;
        });
      } else {
        setState(() {
          _isAuthenticated = false;
          _playerId = null;
        });
      }
    }
    if(_isAuthenticated){
      Uint8List loadedData = await PlayGamesService.loadGame();
      if (loadedData.isNotEmpty) {
        final jsonString = utf8.decode(loadedData);
        final gameData = jsonDecode(jsonString);
        LevelSelectionState.completedLevels = List<int>.from(gameData['completedLevels'] ?? []);
        LevelSelectionState.bestScores = Map<int,int>.from((gameData['bestScores'] ?? {}).map((k,v) => MapEntry(int.parse(k), v)));
      }
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
              if (_isAuthenticated && _playerId != null)
                Text(
                  'Witaj, Player ID: $_playerId',
                  style: const TextStyle(color: Colors.white),
                ),
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
                child: const Text('Levels'),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                child: const Text('Settings'),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  exit(0);
                },
                child: const Text('Exit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
