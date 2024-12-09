import 'dart:typed_data';
import 'package:flutter/services.dart';

class PlayGamesService {
  static const MethodChannel _channel = MethodChannel('play_games_service');

  static Future<bool> signIn() async {
    final bool success = await _channel.invokeMethod('signIn');
    return success;
  }

  static Future<bool> isAuthenticated() async {
    final bool isAuth = await _channel.invokeMethod('isAuthenticated');
    return isAuth;
  }

  static Future<String?> getPlayerId() async {
    final String? playerId = await _channel.invokeMethod('getPlayerId');
    return playerId;
  }

  static Future<bool> saveGame(Uint8List data) async {
    // data to bajty Twojego JSON
    return await _channel.invokeMethod('saveGame', {"data": data});
  }

  static Future<Uint8List> loadGame() async {
    final data = await _channel.invokeMethod('loadGame');
    if (data == null) return Uint8List(0);
    return data;
  }
}
