import 'dart:async';

import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

// Level 2 and 5: the four states by hand, plus Save.
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students; // null = not loaded yet
  Object? _error; // non-null = failed
  final _api = FakeApi(); // Level 2: try FakeApi(empty: true) once
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // initState is synchronous: the framework will not wait for this Future.
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  // Level 5, the honest version: awaited, pop only on success,
  // a message only on failure, context.mounted after every await.
  Future<void> _save() async {
    final n = _students!.length;
    setState(() => _saving = true);
    try {
      await _api.save(n);
      if (!mounted) return;
      Navigator.pop(context);
    } on StateError catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Widget _body() {
    if (_error != null) return ErrorView(onRetry: _load);
    final students = _students;
    if (students == null) return const LoadingView();
    if (students.isEmpty) return const EmptyView();
    return StudentList(students);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('By hand'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Reload',
          onPressed: () => unawaited(_load()),
        ),
      ],
    ),
    body: _body(),
    floatingActionButton: _students == null
        ? null
        : FloatingActionButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
          ),
  );
}
