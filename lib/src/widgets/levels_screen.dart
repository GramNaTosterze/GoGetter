import 'dart:convert';

import 'package:flame/cache.dart';
import 'package:flutter/material.dart';
import 'package:go_getter/src/models/Levels/level.dart';
import 'game_app.dart';
import '../components/board.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  LevelsScreenState createState() => LevelsScreenState();
}

class LevelsScreenState extends State<LevelsScreen> {
  late final BoardComponent board;

  static List<int> completedLevels = [];
  static final List<Level> _levels = [];

  LevelsScreenState() {
    board = BoardComponent();
  }

  static List<Level> getLevels() {
    return _levels;
  }

  void addLevel(Level level) {
    _levels.add(level);
  }

  @override
  void initState() {
    super.initState();
    AssetsCache().readJson("levels/junior/challenge_17.json").then((result) {
      var level = Level.fromJson(result);
      setState(() {
        addLevel(level);
      });
    });
  }

  static void markLevelAsCompleted(int levelIndex) {
    if (!completedLevels.contains(levelIndex)) {
      completedLevels.add(levelIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Levels'),
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
        child: GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 2,
          ),
          itemCount: _levels.length,
          itemBuilder: (context, index) {
            final level = _levels[index];
            final conditions = level;

            bool isCompleted = completedLevels.contains(index);

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? Colors.green : Colors.blue,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameApp(
                      levelConditions: conditions,
                      onLevelCompleted: () {
                        LevelsScreenState.markLevelAsCompleted(index);
                      },
                      selectedLevel: index,
                    ),
                  ),
                );
              },
              child: Text('Poziom ${index + 1}'),
            );
          },
        ),
      ),
    );
  }
}
