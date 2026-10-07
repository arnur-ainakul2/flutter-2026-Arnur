import 'package:flutter/material.dart';

import 'contacts.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Without Expanded around the Column, the RenderFlex overflowed by
    // TODO_FILL_IN_N pixels on the right — run the app, remove Expanded,
    // hot reload, read the console, write the real number here, then put
    // Expanded back.
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(child: Text(contact.initial)),
                if (contact.unread > 0)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.error,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${contact.unread}',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colorScheme.onError),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    contact.email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
