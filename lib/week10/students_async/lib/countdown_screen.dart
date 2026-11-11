import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

// Level 4: a countdown, two ways.
class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _versionB = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Countdown')),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('A: StreamBuilder')),
              ButtonSegment(value: true, label: Text('B: listen')),
            ],
            selected: {_versionB},
            onSelectionChanged: (s) => setState(() => _versionB = s.first),
          ),
        ),
        Expanded(
          child: Center(
            child: _versionB ? const _CountdownB() : const _CountdownA(),
          ),
        ),
      ],
    ),
  );
}

// Version A: StreamBuilder subscribes and cancels for you.
class _CountdownA extends StatefulWidget {
  const _CountdownA();

  @override
  State<_CountdownA> createState() => _CountdownAState();
}

class _CountdownAState extends State<_CountdownA> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
    stream: _stream,
    builder: (context, snapshot) => Text(
      '${snapshot.data ?? 10}',
      style: Theme.of(context).textTheme.displayLarge,
    ),
  );
}

// Version B: you subscribe, so you must cancel.
class _CountdownB extends StatefulWidget {
  const _CountdownB();

  @override
  State<_CountdownB> createState() => _CountdownBState();
}

class _CountdownBState extends State<_CountdownB> {
  int _left = 10;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((i) => setState(() => _left = i));
  }

  @override
  void dispose() {
    // Without this the stream keeps ticking for a screen nobody sees.
    unawaited(_sub.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Text('$_left', style: Theme.of(context).textTheme.displayLarge);
}
