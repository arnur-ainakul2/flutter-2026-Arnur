import 'package:flutter/material.dart';

import 'countdown_screen.dart';
import 'students_future_screen.dart';
import 'students_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('The data arrives later')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const StudentsScreen()),
            ),
            child: const Text('By hand'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const StudentsFutureScreen(),
              ),
            ),
            child: const Text('FutureBuilder'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CountdownScreen()),
            ),
            child: const Text('Countdown'),
          ),
        ],
      ),
    ),
  );
}
