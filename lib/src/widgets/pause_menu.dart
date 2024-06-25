import 'package:flutter/material.dart';

class PauseMenu extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const PauseMenu({
    Key? key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pauza'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: onResume,
            child: const Text('Wznów grę'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onRestart,
            child: const Text('Restartuj grę'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onExit,
            child: const Text('Wyjdź z gry'),
          ),
        ],
      ),
    );
  }
}
