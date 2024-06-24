import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OverlayScreen extends StatelessWidget {
  const OverlayScreen({
    super.key,
    required this.title,
    required this.subtitle,
});
  final String title;
  final String subtitle;

  @override Widget build(BuildContext contex) {
    return Container(
      alignment: const Alignment(0, -0.15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(contex).textTheme.headlineLarge,
          ).animate().slideY(duration: 750.ms, begin: -3, end: 0),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: Theme.of(contex).textTheme.headlineSmall,
          )
            .animate(onPlay: (controller) => controller.repeat())
            .fadeIn(duration: 1.seconds)
            .then()
            .fadeOut(duration: 1.seconds)
        ],
      ),
    );
  }
}