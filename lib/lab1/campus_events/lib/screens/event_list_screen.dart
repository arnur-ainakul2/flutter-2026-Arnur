import 'package:flutter/material.dart';

import '../models/event_category.dart';
import '../models/item.dart';
import '../utils/format.dart';

class EventListScreen extends StatefulWidget {
  final List<Item> items;
  final ValueChanged<Item> onFavourite;
  final ValueChanged<Item> onOpen;

  const EventListScreen({
    super.key,
    required this.items,
    required this.onFavourite,
    required this.onOpen,
  });

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  String _query = '';
  EventCategory? _category;
  bool _pastOnly = false;

  List<Item> get _filteredItems {
    final now = DateTime.now();

    return widget.items.where((item) {
      final matchesQuery = item.title.toLowerCase().contains(
        _query.toLowerCase(),
      );

      final matchesCategory = _category == null || item.category == _category;

      final matchesPast = !_pastOnly || item.when.isBefore(now);

      return matchesQuery && matchesCategory && matchesPast;
    }).toList()..sort((a, b) {
      if (a.isPast != b.isPast) {
        return a.isPast ? 1 : -1;
      }
      return a.when.compareTo(b.when);
    });
  }

  void _clearSearch() {
    setState(() {
      _query = '';
      _category = null;
      _pastOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Search events',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear search and filters',
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) {
                  setState(() {
                    _category = null;
                  });
                },
              ),
              ...EventCategory.values.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    avatar: Icon(category.icon),
                    label: Text(category.label),
                    selected: _category == category,
                    onSelected: (_) {
                      setState(() {
                        _category = category;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              label: const Text('Past events only'),
              selected: _pastOnly,
              onSelected: (value) {
                setState(() {
                  _pastOnly = value;
                });
              },
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No events found',
                  buttonLabel: 'Clear filters',
                  onPressed: _clearSearch,
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => EventCard(
                          item: items[index],
                          onOpen: () => widget.onOpen(items[index]),
                          onFavourite: () => widget.onFavourite(items[index]),
                        ),
                      );
                    }

                    final columns = (constraints.maxWidth / 360)
                        .ceil()
                        .clamp(2, 6)
                        .toInt();

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 160,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) => EventCard(
                        item: items[index],
                        onOpen: () => widget.onOpen(items[index]),
                        onFavourite: () => widget.onFavourite(items[index]),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final Item item;
  final VoidCallback onFavourite;
  final VoidCallback onOpen;

  const EventCard({
    super.key,
    required this.item,
    required this.onFavourite,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: scheme.surfaceContainerHighest,
                    child: Icon(item.category.icon, color: scheme.primary),
                  ),
                  if (item.isFull || item.freePlaces <= 5)
                    Positioned(
                      bottom: -5,
                      right: -12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: item.isFull ? scheme.error : scheme.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.isFull ? 'FULL' : '${item.freePlaces} left',
                          style: TextStyle(color: scheme.onError),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(formatDateTime(item.when)),
                    Text(item.location),
                    if (item.description case final description?)
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavourite,
                tooltip: item.favourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                icon: Icon(
                  item.favourite ? Icons.favorite : Icons.favorite_border,
                  color: item.favourite ? scheme.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(message),
            if (buttonLabel case final label?)
              if (onPressed case final action?)
                TextButton(onPressed: action, child: Text(label)),
          ],
        ),
      ),
    );
  }
}
