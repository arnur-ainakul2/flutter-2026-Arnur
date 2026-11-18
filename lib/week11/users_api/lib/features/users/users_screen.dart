import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NewUserScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: _body(m),
    );
  }

  Widget _body(UsersModel m) {
    if (m.loading && m.items.isEmpty) return const LoadingView();
    return switch (m.error) {
      null => RefreshIndicator(
          onRefresh: m.load,
          child: UserList(m.items),
        ),
      NoConnectionException() => ErrorView(
          icon: Icons.wifi_off,
          text: 'No connection',
          onRetry: m.load,
        ),
      NotFoundException() || UnauthorizedException() => ErrorView(
          icon: Icons.lock_outline,
          text: 'Request rejected',
          onRetry: m.load,
        ),
      ServerException(:final status) => ErrorView(
          icon: Icons.cloud_off,
          text: 'Server error ($status)',
          onRetry: m.load,
        ),
      BadResponseException() => const ErrorView(
          icon: Icons.bug_report_outlined,
          text: 'Could not read the server response',
        ),
    };
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.icon, required this.text, this.onRetry});

  final IconData icon;
  final String text;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 12),
            Text(text),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      );
}

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) => ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final u = users[i];
          return ListTile(
            title: Text(u.name),
            subtitle: Text('${u.email}\n${u.address.city}'),
            isThreeLine: true,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => UserDetailScreen(u)),
            ),
          );
        },
      );
}
