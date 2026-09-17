import 'models.dart';

sealed class ShelfState {
  const ShelfState();
}

class Empty extends ShelfState {
  const Empty();
}

class Ready extends ShelfState {
  final List<Book> books;
  const Ready(this.books);
}

class Broken extends ShelfState {
  final String message;
  const Broken(this.message);
}


String describe(ShelfState state) => switch (state) {
      Empty() => 'The shelf is empty.',
      Ready(books: final books) =>
        'Ready with ${books.length} book(s) on the shelf.',
      Broken(message: final message) => 'Broken: $message',
    };

({int count, double avgPages}) statsOf(List<Book> books) {
  final count = books.length;
  final avgPages = count == 0
      ? 0.0
      : books.fold<int>(0, (sum, book) => sum + book.pages) / count;
  return (count: count, avgPages: avgPages);
}
