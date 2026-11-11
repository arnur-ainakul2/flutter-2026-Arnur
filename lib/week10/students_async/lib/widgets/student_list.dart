import 'package:flutter/material.dart';

import '../api/fake_api.dart';

class StudentList extends StatelessWidget {
  const StudentList(this.students, {super.key, this.compact = false});

  final List<Student> students;
  final bool compact;

  @override
  Widget build(BuildContext context) => ListView.builder(
    itemCount: students.length,
    itemBuilder: (context, i) {
      final s = students[i];
      return ListTile(
        dense: compact,
        leading: CircleAvatar(child: Text(s.name[0])),
        title: Text(s.name),
        subtitle: Text(s.group),
        trailing: Text(s.gpa?.toStringAsFixed(1) ?? '—'),
      );
    },
  );
}
