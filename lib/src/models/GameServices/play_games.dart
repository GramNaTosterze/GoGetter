import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_getter/src/models/GameServices/game_service.dart';
import 'package:go_getter/src/models/GameServices/local.dart';

class PlayGamesService implements GameService{
  final MethodChannel _channel = const MethodChannel('play_games_service');
  final GameService _local = LocalService();
  bool _isAuthentiated = false;
  String? _playerId;
  final Map<int, String> _leaderboard = {
    1: 'CgkI4buRrPYaEAIQAQ',
    2: 'CgkI4buRrPYaEAIQAg',
    3: 'CgkI4buRrPYaEAIQAw',
    4: 'CgkI4buRrPYaEAIQBA',
    5: 'CgkI4buRrPYaEAIQBQ',
  };


  @override
  bool get isAuthenticated => _isAuthentiated;

  @override
  String? get playerId => _playerId;

  @override
  Future<bool> signIn() async {
    try {
      if (!_isAuthentiated) {
        if (! await _channel.invokeMethod('signIn')) return false;
        _isAuthentiated = await _channel.invokeMethod('isAuthenticated');
        _playerId = await _channel.invokeMethod('getPlayerId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('$e');
      }
      return false;
    }
  }

  @override
  Future<bool> saveGame(List<int> completedLevels, Map<int, int> bestScores) async {
    if (!_isAuthentiated) return _local.saveGame(completedLevels, bestScores);


    try {
      final data = {
        "completedLevels": completedLevels,
        "bestScores": bestScores.map((key, value) => MapEntry(key.toString(), value)),
      };
      final jsonString = jsonEncode(data);
      final bytes = Uint8List.fromList(utf8.encode(jsonString));
      return await _channel.invokeMethod('saveGame', {"data": bytes});
    } catch (e) {
      if(kDebugMode) {
        debugPrint("Error during saving game state: $e");
      }
      return false;
    }
  }

  @override
  Future<(List<int>, Map<int,int>)?> loadGame() async {
    if (!_isAuthentiated) return _local.loadGame();

    final data = await _channel.invokeMethod('loadGame');
    if (data.isEmpty) return null;

    final jsonString = utf8.decode(data);
    final gameData = jsonDecode(jsonString);
    final completedLevels = List<int>.from(gameData['completedLevels'] ?? []);
    final bestScores = Map<int,int>.from((gameData['bestScores'] ?? {}).map((k,v) => MapEntry(int.parse(k), v)));

    return (completedLevels, bestScores);
  }

  @override
  Future showLeaderboard(int level) async {
    if (!_isAuthentiated) return;

    if (!_leaderboard.containsKey(level)) return;

    await _channel.invokeMethod('showLeaderboard', {
      'leaderboardId': _leaderboard[level],
    });
  }

  @override
  Future submitScore(int level, int score) async {
    if (!_isAuthentiated) return;

    if (!_leaderboard.containsKey(level)) return;

    await _channel.invokeMethod('submitScore', {
      'leaderboardId': _leaderboard[level],
      'score': score,
    });
  }
}
