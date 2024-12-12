import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_getter/src/models/GameServices/game_service.dart';

class PlayGamesService implements GameService{
  final MethodChannel _channel = const MethodChannel('play_games_service');
  bool _isAuthentiated = false;
  String? _playerId;

  @override
  bool get isAuthenticated {
    if (!_isAuthentiated) {
     getAuthenticationStatus().then((authStatus) {
       return authStatus;
     });
    }
    return _isAuthentiated;
  }

  @override
  String? get playerId {
    if (_playerId == null) {
      getPlayerId().then((id) {
        return id;
      });
    }
    return _playerId;
  }

  @override
  Future<bool> signIn() async {
    if (!_isAuthentiated) {
      return await _channel.invokeMethod('signIn');
    }

    getAuthenticationStatus();
    return await _channel.invokeMethod('signIn');
  }

  @override
  Future<bool> getAuthenticationStatus() async {
    _isAuthentiated = await _channel.invokeMethod('isAuthenticated');
    return _isAuthentiated;
  }

  @override
  Future<String?> getPlayerId() async {
    if (_playerId != null) return _playerId;
    if (!_isAuthentiated) signIn();

    _playerId = await _channel.invokeMethod('getPlayerId');
    return _playerId;
  }

  @override
  Future<bool> saveGame(List<int> completedLevels, Map<int, int> bestScores) async {
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
    final data = await _channel.invokeMethod('loadGame');
    if (data.isEmpty) return null;

    final jsonString = utf8.decode(data);
    final gameData = jsonDecode(jsonString);
    final completedLevels = List<int>.from(gameData['completedLevels'] ?? []);
    final bestScores = Map<int,int>.from((gameData['bestScores'] ?? {}).map((k,v) => MapEntry(int.parse(k), v)));

    return (completedLevels, bestScores);
  }
}
