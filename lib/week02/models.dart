library models;

class Author {
  final String name;
  final String? country;

  const Author({
    required this.name,
    this.country,
  });

  @override
  String toString() {
    return country == null
        ? 'Author($name)'
        : 'Author($name, $country)';
  }
}

enum Genre {
  craft(label: 'Craft & Skills'),
  theory(label: 'Theory'),
  unknown(label: 'Unknown');

  const Genre({required this.label});

  final String label;

  static Genre fromString(String? raw) {
    if (raw == null) return Genre.unknown;
    return Genre.values.firstWhere(
      (g) => g.name.toLowerCase() == raw.toLowerCase(),
      orElse: () => Genre.unknown,
    );
  }
}

abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({
    required this.title,
    required this.year,
  });

  String describe();

  bool get isOld => DateTime.now().year - year > 20;
}

mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Borrow "$title"';
}

class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required String title,
    required int year,
    required this.pages,
    required this.author,
    this.genre = Genre.unknown,
    this.description,
  }) : super(title: title, year: year);

  bool get isLong => pages > 400;

  @override
  String describe() =>
      '$title ($year) by ${author.name} — $pages p, ${genre.label}';

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: (json['title'] as String?) ?? 'Untitled',
      year: _asInt(json['year']),
      pages: _asInt(json['pages']),
      author: _authorFromJson(json['author']),
      genre: Genre.fromString(json['genre'] as String?),
      description: json['description'] as String?,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static Author _authorFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Author(
        name: (value['name'] as String?) ?? 'Unknown',
        country: value['country'] as String?,
      );
    }
    return const Author(name: 'Unknown');
  }

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) {
    return Book(
      title: title ?? this.title,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Book(title: $title, year: $year, pages: $pages, '
        'author: $author, genre: ${genre.label}, '
        'description: ${description ?? '-'})';
  }
}

class Magazine extends LibraryItem {
  final int issue;

  const Magazine({
    required String title,
    required int year,
    required this.issue,
  }) : super(title: title, year: year);

  @override
  String describe() => '$title — issue #$issue ($year)';

  @override
  String toString() => 'Magazine(title: $title, issue: $issue, year: $year)';
}

class Ghost implements LibraryItem {
  @override
  final String title;
  @override
  final int year;

  const Ghost({
    required this.title,
    required this.year,
  });

  @override
  String describe() => 'A ghost entry: $title ($year)';

  @override
  bool get isOld => DateTime.now().year - year > 20;

  @override
  String toString() => 'Ghost(title: $title, year: $year)';
}
