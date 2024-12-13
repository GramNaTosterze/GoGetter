import 'package:flutter/services.dart';

class PlayGamesLeaderboard {
  static const MethodChannel _channel = MethodChannel('play_games_service');

  static Future<void> submitScore(String leaderboardId, int score) async {
    await _channel.invokeMethod('submitScore', {
      'leaderboardId': leaderboardId,
      'score': score,
    });
  }

  static Future<void> showLeaderboard(String leaderboardId) async {
    await _channel.invokeMethod('showLeaderboard', {
      'leaderboardId': leaderboardId,
    });
  }
}
