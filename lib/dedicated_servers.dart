import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DedicatedServers extends StatefulWidget {
  @override
  State<DedicatedServers> createState() => _DedicatedServersState();
}

class _DedicatedServersState extends State<DedicatedServers> {
  _DedicatedServersState() {
    //_fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? apiKey = prefs.getString('api_key');

    if (apiKey == null || apiKey == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key not found!')),
      );
      Navigator.pushNamed(context, '/api_key_input');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://napi.arvancloud.ir/ecc/v1/dedicated-servers/counts'),
        headers: {
          'Authorization': 'apikey ${apiKey}',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        // Parse the response and show it in a ListView
        final List<dynamic> data = json.decode(response.body)['data'];
        setState(() {
          _apiResults = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $e')),
      );
    }
  }

  List<dynamic> _apiResults = [];

  @override
  Widget build(BuildContext context) {
    final String datacenter =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Data Center: $datacenter'),
      ),
      body: Text(datacenter),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/settings'),
        tooltip: 'Settings',
        child: const Icon(Icons.settings),
      ),
    );
  }
}
