import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(title: const Text('Username'), subtitle: Text(user.username)),
          ListTile(title: const Text('Email'), subtitle: Text(user.email)),
          ListTile(
            title: const Text('Phone'),
            subtitle: Text('${user.phone}  (${user.phoneDigits})'),
            onTap: () {}, // Practice 12: url_launcher
          ),
          ListTile(
            title: const Text('Website'),
            subtitle: Text(user.website ?? '—'),
            onTap: () {}, // Practice 12: url_launcher
          ),
          ListTile(
            title: const Text('Address'),
            subtitle: Text(
              '${a.street}, ${a.suite}\n${a.city} ${a.zipcode}\n'
              'geo: ${a.geo.lat}, ${a.geo.lng}',
            ),
          ),
          ListTile(
            title: Text(user.company.name),
            subtitle: Text(user.company.catchPhrase),
          ),
        ],
      ),
    );
  }
}
