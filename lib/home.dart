import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_arven/settings.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = true;
  List<dynamic> _apiResult = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('MyArvan (Unofficial)'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _apiResult.isEmpty
                ? Center(
                    child: ElevatedButton(
                        onPressed: _fetchData, child: const Text('Reload')))
                : ListView.builder(
                    itemCount: _apiResult.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_apiResult[index]['datacenter']),
                        subtitle: Text(_apiResult[index]['count'].toString()),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/dedicated_servers',
                          arguments: _apiResult[index]['datacenter'],
                        ),
                      );
                    },
                    physics: const AlwaysScrollableScrollPhysics(),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/settings'),
        tooltip: 'Settings',
        child: const Icon(Icons.settings),
      ),
    );
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? apiKey = prefs.getString('api_key');

    if (apiKey == null || apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key not found!')),
      );
      Navigator.pushNamed(context, '/settings');
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
          _isLoading = false;
          _apiResult = data;
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
    } finally {
      setState(() {
        _isLoading = false;
        _apiResult = [];
      });
    }
    return;
  }
}
