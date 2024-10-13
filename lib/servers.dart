import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:my_arven/models/region.dart';
import 'package:my_arven/models/server.dart';
import 'package:my_arven/models/server_with_region.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CloudServers extends StatefulWidget {
  @override
  State<CloudServers> createState() => _CloudServersState();
}

class _CloudServersState extends State<CloudServers> {
  Region? _region;
  bool _isLoading = false;
  ServerList _serverList = ServerList(data: []);

  @override
  Widget build(BuildContext context) {
    if (_region == null) {
      _region = ModalRoute.of(context)!.settings.arguments as Region;
      _fetchData();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Data Center: ${_region?.nameEn}'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _serverList.data.isEmpty
                ? Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Nothing Found!'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                              onPressed: _fetchData,
                              child: const Text('Reload')),
                        ]),
                  )
                : ListView.builder(
                    itemCount: _serverList.data.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          title: Text(_serverList.data[index].name),
                          subtitle:
                              Text(_serverList.data[index].status.toString()),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xffe9edf5),
                            ),
                            child: SvgPicture.asset(
                                'assets/os/${_serverList.data[index].image.os}.svg'),
                          ),
                          onTap: () => Navigator.pushNamed(
                                context,
                                '/servers/details',
                                arguments: ServerWithRegion(
                                    server: _serverList.data[index],
                                    region: _region),
                              ));
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
            'https://napi.arvancloud.ir/ecc/v1/regions/${_region?.code ?? ''}/servers'),
        headers: {
          'Authorization': 'apikey ${apiKey}',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final ServerList serverList =
            ServerList.fromJson(json.decode(utf8.decode(response.bodyBytes)));
        setState(() {
          _isLoading = false;
          _serverList = serverList;
        });
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                  'Error: ${response.statusCode}, ${json.decode(utf8.decode(response.bodyBytes))['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to fetch data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
