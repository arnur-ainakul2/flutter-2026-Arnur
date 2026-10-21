import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/profile.dart';

class ProfileScreen extends StatefulWidget {
  final Profile profile;
  final ValueChanged<Profile> onProfileChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final List<Item> items;

  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onProfileChanged,
    required this.themeMode,
    required this.onThemeChanged,
    required this.items,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _groupController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _groupController = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.profile.name != widget.profile.name &&
        _nameController.text != widget.profile.name) {
      _nameController.text = widget.profile.name;
    }

    if (oldWidget.profile.group != widget.profile.group &&
        _groupController.text != widget.profile.group) {
      _groupController.text = widget.profile.group;
    }
  }

  void _saveProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onProfileChanged(
      widget.profile.copyWith(
        name: _nameController.text.trim(),
        group: _groupController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final joinedCount = widget.items.fold(
      0,
      (count, item) => count + (item.contains(widget.profile.name) ? 1 : 0),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (_) => _saveProfile(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _groupController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Your group',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (_) => _saveProfile(),
                validator: (value) =>
                    value == null ||
                        !RegExp(r'^[A-Za-zА-Яа-яЁё0-9-]{2,12}$')
                            .hasMatch(value.trim())
                    ? 'Use 2–12 letters, digits or hyphens'
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _saveProfile,
          child: const Text('Save profile'),
        ),
        const SizedBox(height: 24),
        Text('You are on $joinedCount lists'),
        const SizedBox(height: 24),
        Text('Theme', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('System'),
              selected: widget.themeMode == ThemeMode.system,
              onSelected: (_) => widget.onThemeChanged(ThemeMode.system),
            ),
            ChoiceChip(
              label: const Text('Light'),
              selected: widget.themeMode == ThemeMode.light,
              onSelected: (_) => widget.onThemeChanged(ThemeMode.light),
            ),
            ChoiceChip(
              label: const Text('Dark'),
              selected: widget.themeMode == ThemeMode.dark,
              onSelected: (_) => widget.onThemeChanged(ThemeMode.dark),
            ),
          ],
        ),
      ],
    );
  }
}
