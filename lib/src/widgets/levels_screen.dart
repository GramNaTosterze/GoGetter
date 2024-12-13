
import 'package:flutter/material.dart';
import 'package:go_getter/src/widgets/level_selection.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  LevelsScreenState createState() => LevelsScreenState();
}

class LevelsScreenState extends State<LevelsScreen> {

  @override
  Widget build(BuildContext context) =>
      DefaultTabController(
        length: 4,
        child: Scaffold(

          appBar: AppBar(
            title: const Text('Levels'),
            backgroundColor: const Color(0xff0096ce),
            bottom: const TabBar(
                tabs: [
                  Tab(text: "Starter"),
                  Tab(text: "Junior"),
                  Tab(text: "Expert"),
                  Tab(text: "Master"),
                ]
            ),
          ),
          body: const TabBarView(
              children: [
                LevelSelection(difficulty: DifficultyLevel.starter),
                LevelSelection(difficulty: DifficultyLevel.junior),
                LevelSelection(difficulty: DifficultyLevel.expert),
                LevelSelection(difficulty: DifficultyLevel.master),
              ]
          ),
        )
      );
}
