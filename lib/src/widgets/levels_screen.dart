import 'package:flutter/material.dart';
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
  static List<Map<String, dynamic>> levels = [];

  LevelsScreenState() {
    board = BoardComponent();
  }

  static List<List<Map<String, String>>> getLevels() {
    return levels.map<List<Map<String, String>>>((level) => level['conditions'] as List<Map<String, String>>).toList();
  }

  void addCustomLevel(List<Map<String, String>> conditions) {
    levels.add({'conditions': conditions});
  }

  @override
  void initState() {
    super.initState();

    if (levels.isEmpty) {
      addCustomLevel([
        {'start': 'u3', 'end': 'r1'},
        {'start': 'r3', 'end': 'd3'},
      ]);

      addCustomLevel([
        {'start': 'd2', 'end': 'l1'},
        {'start': 'r1', 'end': 'd1'},
      ]);

      addCustomLevel([
        {'start': 'd2', 'end': 'r2'},
        {'start': 'd1', 'end': 'd3'},
        {'start': 'r2', 'end': 'u3'},
      ]);
    }
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
          itemCount: levels.length,
          itemBuilder: (context, index) {
            final level = levels[index];
            final conditions = level['conditions']!;

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
