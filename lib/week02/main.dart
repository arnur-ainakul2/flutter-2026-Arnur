import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();
  library.open();

  for (final raw in rawBooks) {
    library.add(Book.fromJson(raw));
  }

  print('Opened at: ${library.openedAt}');
  print('');

  print('Every title: ${library.allTitles.toList()}');
  print(
    'Books after 2010: '
    '${library.recentBooks.map((book) => book.title).toList()}',
  );
  print('Average pages: ${library.averagePages}');
  print('Books per author: ${library.bookCountByAuthor}');
  print('Distinct authors: ${library.authorNames}');
  print('Genres present: ${library.genresPresent}');
  print('Country of "Clean Code": ${library.countryOf('Clean Code')}');
  print('Country of "Untitled Notes": ${library.countryOf('Untitled Notes')}');
  print('');

  print(library.displayList.join('\n'));
  print('');

  print(library.report());

  final books = library.items.whereType<Book>().toList();
  final stats = statsOf(books);
  print('Stats record: count=${stats.count}, avgPages=${stats.avgPages}');
  print('');

  print(describe(const Empty()));
  print(describe(Ready(books)));
  print(describe(const Broken('Water damage on shelf 3')));
}
