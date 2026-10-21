import 'package:flutter/material.dart';

import '../data/seed_data.dart';
import '../models/item.dart';
import '../models/profile.dart';
import '../screens/event_list_screen.dart';
import '../screens/favourites_screen.dart';
import '../screens/profile_screen.dart';
import '../routes.dart';

class AppShell extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const AppShell({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late List<Item> _items;
  Profile _profile = Profile.empty();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _items = createSeedItems();
  }

  void _replaceItem(Item updatedItem) {
    setState(() {
      _items = _items
          .map((item) => item.title == updatedItem.title ? updatedItem : item)
          .toList();
    });
  }

  void _toggleFavourite(Item item) {
    _replaceItem(item.copyWith(favourite: !item.favourite));
  }

  void _openItem(Item item) => Navigator.pushNamed<void>(
    context,
    Routes.detail,
    arguments: DetailArguments(
      item: item,
      profileName: _profile.name,
      onChanged: _replaceItem,
      onEdit: (updated) => _replaceItemFrom(item.title, updated),
      onDelete: _deleteItem,
      onSelectProfile: () => setState(() => _selectedIndex = 2),
    ),
  );

  void _replaceItemFrom(String originalTitle, Item updated) {
    setState(() {
      _items = _items
          .map((entry) => entry.title == originalTitle ? updated : entry)
          .toList();
    });
  }

  void _deleteItem(Item item) => setState(
    () => _items = _items.where((entry) => entry.title != item.title).toList(),
  );
  Future<void> _createItem() async {
    final item = await Navigator.pushNamed<Item>(
      context,
      Routes.form,
      arguments: const FormArguments(),
    );
    if (!mounted || item == null) return;
    setState(() => _items = [..._items, item]);
  }

  void _updateProfile(Profile profile) {
    setState(() {
      _profile = profile;
    });
  }

  void _resetData() {
    setState(() {
      _items = createSeedItems();
      _profile = Profile.empty();
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      EventListScreen(
        items: _items,
        onFavourite: _toggleFavourite,
        onOpen: _openItem,
      ),
      FavouritesScreen(
        items: _items,
        onFavourite: _toggleFavourite,
        onOpen: _openItem,
      ),
      ProfileScreen(
        profile: _profile,
        onProfileChanged: _updateProfile,
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
        items: _items,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Events')),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _createItem,
              child: const Icon(Icons.add),
            )
          : null,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const DrawerHeader(child: Text('Campus Events')),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 12),
                    Text('About'),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Campus Events'),
                      content: const Text('Discover and join campus events.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                title: const Row(
                  children: [
                    Icon(Icons.restart_alt),
                    SizedBox(width: 12),
                    Text('Reset data'),
                  ],
                ),
                onTap: () async {
                  Navigator.pop(context);

                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Reset data?'),
                      content: const Text(
                        'Your profile and changes will be cleared.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  );

                  if (!mounted || confirmed != true) return;
                  _resetData();
                },
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
