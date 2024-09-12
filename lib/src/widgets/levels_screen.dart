import 'package:flutter/material.dart';
import 'game_app.dart';
import '../components/board.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  _LevelsScreenState createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  late final BoardComponent board;

  _LevelsScreenState() {
    board = BoardComponent();
  }

  List<Map<String, dynamic>> levels = [];

  void addCustomLevel(List<Map<String, String>> conditions) {
    levels.add({'conditions': conditions});
  }

  List<Map<String, dynamic>> getLevels() {
    return levels;
  }

  @override
  void initState() {
    super.initState();

    addCustomLevel([
      {'start': 'u3', 'end': 'r1'},
      {'start': 'r3', 'end': 'd3'},
    ]);

    addCustomLevel([
      {'start': '2', 'end': '5'},
      {'start': '1', 'end': '3'},
    ]);

    addCustomLevel([
      {'start': '2', 'end': '5'},
      {'start': '1', 'end': '3'},
      {'start': '2', 'end': '3'},
    ]);
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
              Color(0xff348d57),
              Color(0xfff2e8cf),
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

            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameApp(
                      levelConditions: conditions,
                      onLevelCompleted: () {},
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
