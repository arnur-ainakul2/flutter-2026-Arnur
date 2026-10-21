import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/item.dart';
import '../routes.dart';
import '../utils/format.dart';
import 'event_list_screen.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.arguments});
  final DetailArguments arguments;
  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Timer _timer;
  late Item item;
  @override
  void initState() {
    super.initState();
    item = widget.arguments.item;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _action() async {
    final name = widget.arguments.profileName;
    if (name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name to your profile first.'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: widget.arguments.onSelectProfile,
          ),
        ),
      );
      return;
    }
    final removing = item.contains(name);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(removing ? 'Leave this event?' : 'Register?'),
        content: Text(
          removing
              ? 'Remove $name from the attendee list?'
              : 'Add $name to the attendee list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (!mounted || ok != true) return;
    final names = [...item.attendees];
    removing ? names.remove(name) : names.add(name);
    setState(() => item = item.copyWith(attendees: names));
    widget.arguments.onChanged(item);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text('This event will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || ok != true) return;
    widget.arguments.onDelete(item);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (taken: taken, free: free) = item.places;
    final countdown = Countdown.from(item.when);
    final label = switch (countdown) {
      Upcoming(:final remaining) =>
        'Starts in ${remaining.inDays}d ${remaining.inHours.remainder(24)}h',
      Started(:final elapsed) => 'Started ${elapsed.inMinutes} min ago',
      Ended() => 'Ended',
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'delete') {
                await _delete();
              } else if (v == 'edit') {
                final result = await Navigator.pushNamed<Item>(
                  context,
                  Routes.form,
                  arguments: FormArguments(
                    item: item,
                    currentCount: item.count,
                  ),
                );
                if (!mounted || result == null) return;
                setState(() => item = result);
                widget.arguments.onEdit(result);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Image.asset(
                'assets/event_header.png',
                height: 190,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                height: 190,
                color: scheme.scrim.withValues(alpha: .35),
              ),
              Positioned(
                left: 16,
                top: 16,
                child: Chip(
                  avatar: Icon(item.category.icon),
                  label: Text(item.category.label),
                ),
              ),
              Positioned(right: 16, top: 16, child: Chip(label: Text(label))),
              Center(
                heightFactor: 3,
                child: Icon(
                  item.category.icon,
                  size: 58,
                  color: scheme.onPrimary,
                ),
              ),
            ],
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      const Tab(text: 'About'),
                      Tab(text: 'Attendees (${item.count})'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Text(formatDateTime(item.when)),
                            const SizedBox(height: 8),
                            Text(
                              item.isOnline
                                  ? 'Online: ${item.location}'
                                  : item.location,
                            ),
                            const SizedBox(height: 8),
                            Text('$taken attending · $free places left'),
                            if (item.description case final description?)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(description),
                              ),
                          ],
                        ),
                        item.attendees.isEmpty
                            ? const EmptyState(
                                icon: Icons.people_outline,
                                message: 'Nobody is on this list yet',
                              )
                            : ListView(
                                children: item.attendees
                                    .map(
                                      (name) => ListTile(
                                        title: Text(
                                          name,
                                          style:
                                              name ==
                                                  widget.arguments.profileName
                                              ? const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                )
                                              : null,
                                        ),
                                        trailing:
                                            name == widget.arguments.profileName
                                            ? const Chip(label: Text('You'))
                                            : null,
                                      ),
                                    )
                                    .toList(),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      item.isFull &&
                          !item.contains(widget.arguments.profileName)
                      ? null
                      : _action,
                  child: Text(
                    item.contains(widget.arguments.profileName)
                        ? 'Leave'
                        : 'Register',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
