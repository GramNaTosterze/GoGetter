import 'package:flutter/material.dart';

class PauseMenu extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const PauseMenu({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pause'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: onResume,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                ),
                Text(' '),
                Text('Resume'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onRestart,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.replay,
                  color: Colors.white,
                ),
                Text(' '),
                Text('Restart'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onExit,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                Text(' '),
                Text('Exit'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
