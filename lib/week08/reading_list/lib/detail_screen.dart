import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Book details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text('Author: ${book.author}', style: theme.textTheme.bodyLarge),
            Text('Pages: ${book.pages}', style: theme.textTheme.bodyLarge),
            Text(
              book.year == null ? 'Year unknown' : 'Year: ${book.year}',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              'Read: ${book.read ? 'Yes' : 'No'}',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(BookAction.toggleRead),
              child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete'),
                    content: Text("Delete '${book.title}'?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (!context.mounted) return;
                if (confirmed == true) {
                  Navigator.of(context).pop(BookAction.delete);
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
