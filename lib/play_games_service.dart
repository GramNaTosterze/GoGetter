import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class PlayGamesService {
  static const MethodChannel _channel = MethodChannel('play_games_service');

  static Future<bool> isAuthenticated() async {
    if (Platform.isAndroid) {
      final bool isAuthenticated = await _channel.invokeMethod(
          'isAuthenticated');
      return isAuthenticated;
    }
    return false;
  }

  static Future<bool> signIn() async {
    if (Platform.isAndroid) {
      final bool success = await _channel.invokeMethod('signIn');
      return success;
    }
    return false;
  }

  static Future<String?> getPlayerId() async {
    if (Platform.isAndroid) {
      final String? playerId = await _channel.invokeMethod('getPlayerId');
      return playerId;
    }
    return "";
  }
}
