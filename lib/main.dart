import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/server_details_screen.dart';
import 'screens/servers_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyArvan (Unofficial)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/servers': (context) => const ServersScreen(),
        '/servers/details': (context) => const ServerDetailsScreen(),
      },
    );
  }
}
