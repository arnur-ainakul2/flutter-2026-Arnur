import 'package:flutter/material.dart';

import 'contact_card.dart';
import 'contacts.dart';

class ContactList extends StatelessWidget {
  const ContactList({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const Text('20 contacts'),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: contacts.length,
              itemBuilder: (context, i) => ContactCard(contact: contacts[i]),
              separatorBuilder: (context, i) => const Divider(),
            ),
          ),
        ],
      );
}
