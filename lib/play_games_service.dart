import 'package:flutter/services.dart';

class PlayGamesService {
  static const MethodChannel _channel = MethodChannel('play_games_service');

  static Future<bool> isAuthenticated() async {
    final bool isAuthenticated = await _channel.invokeMethod('isAuthenticated');
    return isAuthenticated;
  }

  static Future<bool> signIn() async {
    final bool success = await _channel.invokeMethod('signIn');
    return success;
  }

  static Future<String?> getPlayerId() async {
    final String? playerId = await _channel.invokeMethod('getPlayerId');
    return playerId;
  }
}
