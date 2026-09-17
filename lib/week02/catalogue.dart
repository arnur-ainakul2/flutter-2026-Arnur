import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  late final DateTime openedAt;

  String? _cachedReport;

  void add(LibraryItem item) {
    items.add(item);
  }

  void open() {
    openedAt = DateTime.now();
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }
    return null;
  }

  String countryOf(String title) {
    return findByTitle(title)?.author.country ?? 'unknown';
  }

  String report() {
    return _cachedReport ??= _buildReport();
  }

  String _buildReport() {
    final buffer = StringBuffer();
    buffer.writeln('Library report (${items.length} items):');

    for (final item in items) {
      buffer.writeln('- ${item.describe()}');

      if (item is Book) {
        final description = item.description;
        if (description != null) {
          buffer.writeln('  $description');
        }
      }
    }

    return buffer.toString();
  }

  // --- Level 4: Collections ------------------------------------------

  Iterable<String> get allTitles => items.map((item) => item.title);

  Iterable<Book> get recentBooks =>
      items.whereType<Book>().where((book) => book.year > 2010);

 
  double get averagePages => items.whereType<Book>().isEmpty
      ? 0
      : items.whereType<Book>().fold<int>(0, (sum, book) => sum + book.pages) /
          items.whereType<Book>().length;

  Map<String, int> get bookCountByAuthor =>
      items.whereType<Book>().fold<Map<String, int>>(
        {},
        (map, book) => map
          ..update(book.author.name, (count) => count + 1, ifAbsent: () => 1),
      );

  Set<String> get authorNames =>
      items.whereType<Book>().map((book) => book.author.name).toSet();

  Set<Genre> get genresPresent =>
      items.whereType<Book>().map((book) => book.genre).toSet();

  List<String> get displayList => [
        'CATALOGUE',
        for (final book in items.whereType<Book>())
          '${book.title} (${book.year})',
        ...authorNames,
        if (items.whereType<Book>().any((book) => book.pages == 0))
          '(incomplete data)',
      ];
}
