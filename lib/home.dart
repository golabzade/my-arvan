import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_arven/models/region.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;
  RegionList _regionList = RegionList(data: []);

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
            : _regionList.data.isEmpty
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Nothing Found!'),
                          ElevatedButton(
                              onPressed: _fetchData,
                              child: const Text('Reload')),
                        ]),
                  )
                : ListView.builder(
                    itemCount: _regionList.data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Row(
                          children: [
                            Badge(
                              label: Text(_regionList.data[index].state),
                              backgroundColor:
                                  _regionList.data[index].state == 'up'
                                      ? Colors.green
                                      : Colors.red,
                              alignment: AlignmentDirectional.topEnd,
                              offset: const Offset(15, -5),
                              child: Text(_regionList.data[index].nameEn),
                            )
                          ],
                        ),
                        subtitle: Text(_regionList.data[index].cityEn),
                        leading: CircleAvatar(
                          child: SvgPicture.network(_regionList.data[index].image),
                        ),
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/servers',
                          arguments: _regionList.data[index],
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
      setState(() {
        _isLoading = false;
      });
      Navigator.pushNamed(context, '/settings');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://napi.arvancloud.ir/ecc/v2/datacenters'),
        headers: {
          'Authorization': 'apikey ${apiKey}',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final RegionList regionList = RegionList.fromJson(json.decode(response.body));
        setState(() {
          _isLoading = false;
          _regionList = regionList;
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
