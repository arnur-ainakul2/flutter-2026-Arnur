import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

// Level 3: the same screen with FutureBuilder, done right.
class StudentsFutureScreen extends StatefulWidget {
  const StudentsFutureScreen({super.key});

  @override
  State<StudentsFutureScreen> createState() => _StudentsFutureScreenState();
}

class _StudentsFutureScreenState extends State<StudentsFutureScreen> {
  final _api = FakeApi();
  // late but NOT final: _retry() is the one place a new Future is allowed.
  late Future<List<Student>> _future;
  int _attempt = 0; // a new key per retry, so FutureBuilder starts clean
  bool _compact = false;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchStudents(); // assigned here, never inside build
  }

  void _retry() => setState(() {
    _attempt++;
    _future = _api.fetchStudents();
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('FutureBuilder'),
      actions: [
        Switch(value: _compact, onChanged: (v) => setState(() => _compact = v)),
      ],
    ),
    body: FutureBuilder<List<Student>>(
      key: ValueKey(_attempt),
      future: _future, // the field, never a call
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorView(onRetry: _retry);
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView();
        }
        final list = snapshot.data ?? const <Student>[];
        if (list.isEmpty) return const EmptyView();
        return StudentList(list, compact: _compact);
      },
    ),
  );
}
