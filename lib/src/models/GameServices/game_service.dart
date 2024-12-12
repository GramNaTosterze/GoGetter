import 'package:flutter/foundation.dart';
import 'package:go_getter/src/models/GameServices/local.dart';
import 'package:go_getter/src/models/GameServices/play_games.dart';

abstract class GameService {
  static GameService? _instance;

  factory GameService() {
    _instance ??= switch (defaultTargetPlatform) {
      TargetPlatform.android => PlayGamesService(),
      _ => LocalService(),
    };
    return _instance!;
  }


  bool get isAuthenticated;
  String? get playerId;

  Future<bool> signIn();
  Future<bool> getAuthenticationStatus();
  Future<String?> getPlayerId();
  Future<bool> saveGame(List<int> completedLevels, Map<int, int> bestScores);
  Future<(List<int>, Map<int,int>)?> loadGame();
}
