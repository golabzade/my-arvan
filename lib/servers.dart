import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_arven/models/region.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DedicatedServers extends StatefulWidget {
  @override
  State<DedicatedServers> createState() => _DedicatedServersState();
}

class _DedicatedServersState extends State<DedicatedServers> {
  Region? _datacenter;
  bool _isLoading = false;
  List<dynamic> _apiResult = [];

  @override
  Widget build(BuildContext context) {
    if (_datacenter == null) {
      _datacenter = ModalRoute.of(context)!.settings.arguments as Region;
      _fetchData();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Data Center: ${_datacenter?.nameEn}'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _apiResult.isEmpty
                ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Nothing Found!'),
                        ElevatedButton(
                            onPressed: _fetchData, child: const Text('Reload')),
                      ]),
                )
                : ListView.builder(
                    itemCount: _apiResult.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_apiResult[index]['datacenter']),
                        subtitle: Text(_apiResult[index]['count'].toString()),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/servers/info',
                          arguments: _apiResult[index]['datacenter'],
                        ),
                      );
                    },
                    physics: const AlwaysScrollableScrollPhysics(),
                  ),
      ),
    );
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiKey = prefs.getString('api_key') ?? '';

    try {
      final response = await http.get(
        Uri.parse(
            'https://napi.arvancloud.ir/ecc/v1/regions/${_datacenter?.code ?? ''}/servers'),
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
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error: ${response.statusCode}, ${json.decode(response.body)['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
