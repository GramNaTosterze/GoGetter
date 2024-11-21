import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'levels_screen.dart';
import '../../play_games_service.dart'; // Upewnij się, że ścieżka jest poprawna
import 'dart:io';

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
      // Spróbuj zalogować użytkownika
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
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    // Spróbuj zalogować użytkownika
                    bool signedIn = await PlayGamesService.signIn();
                    if (signedIn) {
                      String? playerId = await PlayGamesService.getPlayerId();
                      setState(() {
                        _isAuthenticated = true;
                        _playerId = playerId;
                      });
                    }
                  },
                  child: const Text('Zaloguj się do Play Games'),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isAuthenticated
                    ? () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const GameApp()),
                  // );
                }
                    : null, // Przycisk nieaktywny, jeśli niezalogowany
                child: const Text('Start Game'),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
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
