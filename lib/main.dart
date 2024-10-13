import 'package:flutter/material.dart';
import 'package:my_arven/server_details.dart';
import 'package:my_arven/servers.dart';
import 'package:my_arven/settings.dart';
import 'package:my_arven/home.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyArvan (Unofficial)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/settings': (context) => SettingsScreen(),
        '/servers': (context) => CloudServers(),
        '/servers/details': (context) => CloudServerDetails(),
      },
    );
  }
}
