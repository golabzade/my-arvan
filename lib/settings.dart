import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  String? _savedApiKey;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  // Load the API key from local storage
  void _loadApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedApiKey = prefs.getString('api_key');
      if (_savedApiKey != null) {
        _apiKeyController.text = _savedApiKey!;
      }
    });
  }

  // Save the API key to local storage
  Future<void> _saveApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', _apiKeyController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('API Key saved!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(labelText: 'API Key'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async => await _saveApiKey(),
              child: const Text('Save API Key'),
            )
          ],
        ),
      ),
    );
  }
}
