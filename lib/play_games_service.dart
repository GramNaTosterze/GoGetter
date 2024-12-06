import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class PlayGamesService {
  static const MethodChannel _channel = MethodChannel('play_games_service');

  static Future<bool> isAuthenticated() async {
    if (Platform.isAndroid && !kDebugMode) {
      final bool isAuthenticated = await _channel.invokeMethod(
          'isAuthenticated');
      return isAuthenticated;
    }
    return false;
  }

  static Future<bool> signIn() async {
    if (Platform.isAndroid && !kDebugMode) {
      final bool success = await _channel.invokeMethod('signIn');
      return success;
    }
    return false;
  }

  static Future<String?> getPlayerId() async {
    if (Platform.isAndroid && !kDebugMode) {
      final String? playerId = await _channel.invokeMethod('getPlayerId');
      return playerId;
    }
    return "";
  }

  static Future<bool> saveGame(Uint8List data) async {
    final bool success = await _channel.invokeMethod('saveGame', {'data': data});
    return success;
  }

  static Future<Uint8List?> loadGame() async {
    final Uint8List? data = await _channel.invokeMethod('loadGame');
    return data;
  }
}
