import 'event_category.dart';

class Item {
  final String title;
  final EventCategory category;
  final DateTime when;
  final int limit;
  final String location;
  final List<String> _attendees;
  final bool isOnline;
  final String? description;
  final bool favourite;

  const Item({
    required this.title,
    required this.category,
    required this.when,
    required this.limit,
    required this.location,
    required List<String> attendees,
    required this.isOnline,
    required this.description,
    required this.favourite,
    // The public parameter name keeps call sites readable; storage stays private.
    // ignore: prefer_initializing_formals
  }) : _attendees = attendees;

  List<String> get attendees => List.unmodifiable(_attendees);

  int get count => _attendees.length;

  int get freePlaces => limit - count;

  bool get isFull => count >= limit;

  bool get isPast => when.isBefore(DateTime.now());

  bool contains(String name) => _attendees.contains(name);

  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Item copyWith({
    String? title,
    EventCategory? category,
    DateTime? when,
    int? limit,
    String? location,
    List<String>? attendees,
    bool? isOnline,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) {
    return Item(
      title: title ?? this.title,
      category: category ?? this.category,
      when: when ?? this.when,
      limit: limit ?? this.limit,
      location: location ?? this.location,
      attendees: List.unmodifiable(attendees ?? _attendees),
      isOnline: isOnline ?? this.isOnline,
      description: clearDescription ? null : (description ?? this.description),
      favourite: favourite ?? this.favourite,
    );
  }

  Item.empty()
    : title = '',
      category = EventCategory.tech,
      when = DateTime.now().add(const Duration(days: 1)),
      limit = 10,
      location = '',
      _attendees = const [],
      isOnline = false,
      description = null,
      favourite = false;
}
