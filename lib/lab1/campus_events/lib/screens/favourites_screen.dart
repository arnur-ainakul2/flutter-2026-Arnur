import 'package:flutter/material.dart';

import '../models/item.dart';
import 'event_list_screen.dart';

class FavouritesScreen extends StatelessWidget {
  final List<Item> items;
  final ValueChanged<Item> onFavourite;
  final ValueChanged<Item> onOpen;

  const FavouritesScreen({
    super.key,
    required this.items,
    required this.onFavourite,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final favourites = items.where((item) => item.favourite).toList();

    if (favourites.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        message: 'You have no favourite events yet',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: favourites.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = favourites[index];

        return EventCard(
          item: item,
          onOpen: () => onOpen(item),
          onFavourite: () => onFavourite(item),
        );
      },
    );
  }
}
