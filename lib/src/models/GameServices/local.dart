
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:go_getter/src/models/GameServices/game_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalService implements GameService {

  @override
  bool get isAuthenticated => false;

  @override
  String? get playerId => null;

  @override
  Future<(List<int>, Map<int, int>)?> loadGame() async {
    var prefs = SharedPreferencesAsync();

    final completedLevelsStr = await prefs.getStringList('completedLevels') ?? [];
    final completedLevels = List<int>.from(completedLevelsStr.map((el) => int.parse(el)).toList());

    final bestScoresJson = await prefs.getString('bestScores');
    final bestScoresStr = jsonDecode(bestScoresJson ?? '');
    final bestScores = Map<int,int>.from((bestScoresStr).map((k,v) => MapEntry(int.parse(k), v)));

    return (completedLevels, bestScores);
  }

  @override
  Future<bool> saveGame(List<int> completedLevels, Map<int, int> bestScores) async {
    try {
      var prefs = SharedPreferencesAsync();

      await prefs.setStringList('completedLevels', completedLevels.map((el) => el.toString()).toList());
      final bestScoresJsonString = jsonEncode(bestScores.map((key, value) => MapEntry(key.toString(), value)));
      await prefs.setString('bestScores', bestScoresJsonString);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('$e');
      }
    }
    return false;
  }

  @override
  Future<bool> signIn() async {
    return true;
  }

  @override
  Future showLeaderboard(int level) async {} // no Leaderboard in Local play

  @override
  Future submitScore(int level, int score) async {} // no Leaderboard in Local play

}