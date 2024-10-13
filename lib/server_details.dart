import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:my_arven/models/message_response.dart';
import 'package:my_arven/models/region.dart';
import 'package:my_arven/models/server.dart';
import 'package:my_arven/models/server_with_region.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CloudServerDetails extends StatefulWidget {
  @override
  State<CloudServerDetails> createState() => _CloudServerDetailsState();
}

class _CloudServerDetailsState extends State<CloudServerDetails> {
  Server? _server;
  Region? _region;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (_server == null || _region == null) {
      ServerWithRegion swr =
          ModalRoute.of(context)!.settings.arguments as ServerWithRegion;
      _server = swr.server;
      _region = swr.region;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Server: ${_server?.name}'),
      ),
      body: RefreshIndicator(
          onRefresh: _fetchData,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _region == null || _server == null
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
                  : Padding(
                      padding: const EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(children: [
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: const Color(0xfff5f7fa),
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: const Color(0xffe9edf5),
                                    ),
                                    child: SvgPicture.asset(
                                        'assets/os/${_server?.image.os}.svg'),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    children: [
                                      Text(
                                        _server?.name ?? '',
                                        style: const TextStyle(
                                          fontSize: 24,
                                        ),
                                      ),
                                      Text(_server?.status.toString() ?? '')
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                              decoration: BoxDecoration(
                                  color: const Color(0xfff5f7fa),
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.all(16),
                              child: Column(children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _callActionToServer('terminate'),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 8, 0, 8),
                                          child: Column(
                                            children: [
                                              SvgPicture.asset(
                                                  'assets/power-on.svg',
                                                  height: 16),
                                              const SizedBox(height: 4),
                                              const Text('Terminate'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _callActionToServer('power-off'),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 8, 0, 8),
                                          child: Column(
                                            children: [
                                              SvgPicture.asset(
                                                  'assets/power-on.svg',
                                                  height: 16),
                                              const SizedBox(height: 4),
                                              const Text('Power Off'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
                                const SizedBox(height: 32),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _callActionToServer('hard-reboot'),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 8, 0, 8),
                                          child: Column(
                                            children: [
                                              SvgPicture.asset(
                                                  'assets/reboot.svg',
                                                  height: 16),
                                              const SizedBox(height: 4),
                                              const Text('Hard Reboot'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _callActionToServer('reboot'),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 8, 0, 8),
                                          child: Column(
                                            children: [
                                              SvgPicture.asset(
                                                  'assets/reboot.svg',
                                                  height: 16),
                                              const SizedBox(height: 4),
                                              const Text('Reboot'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
                                const SizedBox(height: 32),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _callActionToServer('power-on'),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 8, 0, 8),
                                          child: Column(
                                            children: [
                                              SvgPicture.asset(
                                                  'assets/power-on.svg',
                                                  height: 16),
                                              const SizedBox(height: 4),
                                              const Text('Power On'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ])
                              ]))
                        ]),
                      ),
                    )),
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
            'https://napi.arvancloud.ir/ecc/v1/regions/${_region?.code ?? ''}/servers/${_server?.id ?? ''}'),
        headers: {
          'Authorization': 'apikey $apiKey',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final Server server = Server.fromJson(json.decode(response.body)['data']);
        setState(() {
          _isLoading = false;
          _server = server;
        });
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                  'Error: ${response.statusCode}, ${json.decode(response.body)['message']}')),
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

  Future<void> _callActionToServer(String action) async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiKey = prefs.getString('api_key') ?? '';

    try {
      final response = await http.post(
        Uri.parse(
            'https://napi.arvancloud.ir/ecc/v1/regions/${_region?.code}/servers/${_server?.id}/$action'),
        headers: {
          'Authorization': 'apikey ${apiKey}',
          'Accept': 'application/json'
        },
      );
      if (response.statusCode == 202) {
        final MessageResponse messageResponse = MessageResponse.fromJson(
            json.decode(utf8.decode(response.bodyBytes)));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.green,
              content: Text(messageResponse.message)),
        );
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
