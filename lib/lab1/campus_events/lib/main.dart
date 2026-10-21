import 'package:flutter/material.dart';

import 'shell/app_shell.dart';
import 'routes.dart';

void main() {
  runApp(const CampusEventsApp());
}

class CampusEventsApp extends StatefulWidget {
  const CampusEventsApp({super.key});

  @override
  State<CampusEventsApp> createState() => _CampusEventsAppState();
}

class _CampusEventsAppState extends State<CampusEventsApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _changeTheme(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Events',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const ColorScheme.light().primary,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const ColorScheme.light().primary,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      initialRoute: Routes.home,
      routes: {
        Routes.home: (_) =>
            AppShell(themeMode: _themeMode, onThemeChanged: _changeTheme),
      },
      onGenerateRoute: generateAppRoute,
      onUnknownRoute: (_) =>
          generateAppRoute(const RouteSettings(name: Routes.unknown)),
    );
  }
}
