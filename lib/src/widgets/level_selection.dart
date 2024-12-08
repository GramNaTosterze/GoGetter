
import 'dart:convert';

import 'package:flame/cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_getter/src/components/components.dart';
import 'package:go_getter/src/models/models.dart';
import 'package:go_getter/src/widgets/game_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DifficultyLevel {
  starter,
  junior,
  expert,
  master;

  @override
  String toString() {
    return switch (this) {
      DifficultyLevel.starter => "starter",
      DifficultyLevel.junior => "junior",
      DifficultyLevel.expert => "expert",
      DifficultyLevel.master => "master",
    };
  }

  DifficultyLevel? next() {
    return switch (this) {
      DifficultyLevel.starter => DifficultyLevel.junior,
      DifficultyLevel.junior => DifficultyLevel.expert,
      DifficultyLevel.expert => DifficultyLevel.master,
      DifficultyLevel.master => null,
    };
  }
}

class LevelSelection extends StatefulWidget {
  final DifficultyLevel difficulty;
  const LevelSelection({
    required this.difficulty,
    super.key
  });

  @override
  State<StatefulWidget> createState() => LevelSelectionState(difficulty);

}

class LevelSelectionState extends State<LevelSelection> {

  late final BoardComponent board;
  late final DifficultyLevel difficulty;
  late final List<ElevatedButton> levelButtons;

  static List<int> completedLevels = [];
  static Map<int, int> bestScores = {};
  final List<String> _levels = [];

  static Level? currentLevel;

  LevelSelectionState(this.difficulty) {
    //difficulty = widget.difficulty;
    board = BoardComponent();
    SharedPreferences.getInstance().then((prefs) {
      var list = prefs.getStringList("completedLevels");
      if (list != null) {
        setState(() {
          completedLevels = list.map((el) => int.parse(el)).toList();
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _initLevelSelection();
  }

  Future _initLevelSelection() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);
    final levelPaths = manifestMap.keys
      .where((String key) => key.contains('levels/$difficulty/'))
      .toList();

    levelPaths.sort((a,b) =>
        int.parse(a.replaceFirst('assets/levels/$difficulty/challenge_', '').replaceFirst('.json', ''))
        .compareTo(int.parse(b.replaceFirst('assets/levels/$difficulty/challenge_', '').replaceFirst('.json', '')))
    );

    final buttons = levelPaths.map((String e) {
      var levelIdx = int.parse(e.replaceFirst('assets/levels/$difficulty/challenge_', '').replaceFirst('.json', ''));

      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: completedLevels.contains(levelIdx) ? Colors.green : Colors.blue,
        ),
        onPressed: () async {
          await loadLevel(e);
          if (context.mounted) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => GameApp(
                onLevelCompleted: () {
                  markLevelAsCompleted(levelIdx);
                },
                selectedLevel: currentLevel ?? Level(-1, []),
              ),
            ));
          }
        },
        child: Text('$levelIdx'),
      );
    }).toList();

    setState(() {
      _levels.addAll(levelPaths);
      levelButtons = buttons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: switch (difficulty) {
        DifficultyLevel.starter => const Color(0xff739e07),
        DifficultyLevel.junior => const Color(0xffbd6d02),
        DifficultyLevel.expert => const Color(0xff930000),
        DifficultyLevel.master => const Color(0xff1632ff),
      },
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 2,
        ),
        itemCount: levelButtons.length,
        itemBuilder: (context, index) {
          return levelButtons[index];
        },
      ),
    );
  }

  Future loadLevel(String levelPath) async {
    var json = await AssetsCache().readJson(levelPath.replaceFirst('assets/', ''));
    setState(() {
      var levelId = int.parse(levelPath.replaceFirst('assets/levels/$difficulty/challenge_', '').replaceFirst('.json', ''));
      currentLevel = Level.fromJson(levelId, json);
    });
  }

  static Future loadNext() async {
    if (currentLevel == null) return;

    int nextLevel = currentLevel!.idx + 1;

    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);

    for (var difficulty in DifficultyLevel.values) {
      var levelPath = 'assets/levels/$difficulty/challenge_$nextLevel.json';
      if (manifestMap.keys.contains(levelPath)) {
        var json = await AssetsCache().readJson(
            levelPath.replaceFirst('assets/', ''));
        var levelId = int.parse(
            levelPath.replaceFirst('assets/levels/$difficulty/challenge_', '')
                .replaceFirst('.json', ''));
        currentLevel = Level.fromJson(levelId, json);
      }
    }
  }

  static void markLevelAsCompleted(int levelId) {
    if (completedLevels.contains(levelId)) return;
    completedLevels.add(levelId);

    SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList('completedLevels', completedLevels.map((el) => el.toString()).toList());
    });
  }
}