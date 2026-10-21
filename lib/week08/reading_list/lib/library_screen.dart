import 'package:flutter/material.dart';

import 'add_book_screen.dart';
import 'detail_screen.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';

enum Filter { all, unread, read }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed];
  Filter _filter = Filter.all;

  List<Book> get _visible => switch (_filter) {
        Filter.all => _books,
        Filter.unread => unread(_books),
        Filter.read => _books.where((b) => b.read).toList(),
      };

  String _chipLabel(Filter f) => switch (f) {
        Filter.all => 'All',
        Filter.unread => 'Unread',
        Filter.read => 'Read',
      };

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      appBar: AppBar(title: Text('Reading list (${visible.length})')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _HeaderStat(
                      value: _books.length.toString(),
                      label: 'Books',
                    ),
                  ),
                  Expanded(
                    child: _HeaderStat(
                      value: totalPages(_books).toString(),
                      label: 'Pages',
                    ),
                  ),
                  Expanded(
                    child: _HeaderStat(
                      value: unread(_books).length.toString(),
                      label: 'Unread',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (final f in Filter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_chipLabel(f)),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: visible.length,
              itemBuilder: (context, i) {
                final book = visible[i];
                return BookTile(
                  book: book,
                  onToggle: () => setState(() => book.read = !book.read),
                  onTap: () async {
                    final action = await Navigator.of(context)
                        .push<BookAction>(MaterialPageRoute(
                      builder: (_) => DetailScreen(book: book),
                    ));
                    if (!mounted) return;
                    switch (action) {
                      case null:
                        break;
                      case BookAction.toggleRead:
                        setState(() => book.read = !book.read);
                      case BookAction.delete:
                        setState(() => _books.remove(book));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final book = await Navigator.of(context).push<Book>(MaterialPageRoute(
            builder: (_) => const AddBookScreen(),
          ));
          if (!mounted || book == null) return;
          setState(() => _books.add(book));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.headlineSmall),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
