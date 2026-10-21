import 'package:flutter/material.dart';

import 'models/item.dart';
import 'screens/event_detail_screen.dart';
import 'screens/item_form_screen.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
  static const unknown = '/unknown';
}

class DetailArguments {
  const DetailArguments({
    required this.item,
    required this.profileName,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onSelectProfile,
  });
  final Item item;
  final String profileName;
  final ValueChanged<Item> onChanged;
  final ValueChanged<Item> onEdit;
  final ValueChanged<Item> onDelete;
  final VoidCallback onSelectProfile;
}

class FormArguments {
  const FormArguments({this.item, this.currentCount = 0});
  final Item? item;
  final int currentCount;
}

Route<dynamic> generateAppRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.detail:
      if (settings.arguments case final DetailArguments args) {
        return MaterialPageRoute<void>(
          builder: (_) => EventDetailScreen(arguments: args),
        );
      }
      return MaterialPageRoute<void>(builder: (_) => const _NotFoundScreen());
    case Routes.form:
      if (settings.arguments case final FormArguments args) {
        return MaterialPageRoute<Item>(
          builder: (_) =>
              ItemFormScreen(item: args.item, currentCount: args.currentCount),
        );
      }
      return MaterialPageRoute<void>(builder: (_) => const _NotFoundScreen());
    default:
      return MaterialPageRoute<void>(builder: (_) => const _NotFoundScreen());
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Not found')),
    body: const Center(child: Text('Not found')),
  );
}
