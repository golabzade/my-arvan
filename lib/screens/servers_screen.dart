import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/cloud_provider.dart';
import '../models/region.dart';
import '../models/server.dart';
import '../models/server_with_region.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/unified_api_service.dart';
import '../widgets/status_badge.dart';

class ServersScreen extends StatefulWidget {
  const ServersScreen({super.key});

  @override
  State<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends State<ServersScreen> {
  final StorageService _storageService = StorageService();
  final UnifiedApiService _apiService = UnifiedApiService();

  Region? _region;
  CloudProvider _provider = CloudProvider.arvanCloud;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;
  ServerList _serverList = const ServerList(data: []);
  String _searchQuery = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Region) {
        _region = args;
        _fetchData();
      } else {
        _errorMessage = 'No region specified.';
      }
      _isInitialized = true;
    }
  }

  Future<void> _fetchData() async {
    if (_region == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final provider = await _storageService.getActiveProvider();
    final apiKey = await _storageService.getApiKey(provider);

    if (!mounted) return;

    setState(() {
      _provider = provider;
    });

    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushNamed(context, '/settings');
      return;
    }

    try {
      final serverList = await _apiService.fetchServers(
        provider,
        apiKey,
        _region!.code,
      );
      if (!mounted) return;
      setState(() {
        _serverList = serverList;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load servers: $e';
        _isLoading = false;
      });
    }
  }

  List<Server> get _filteredServers {
    if (_searchQuery.isEmpty) return _serverList.data;
    final query = _searchQuery.toLowerCase();
    return _serverList.data.where((server) {
      return server.name.toLowerCase().contains(query) ||
          server.status.toString().toLowerCase().contains(query) ||
          server.image.os.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredServers;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_region != null ? 'DC: ${_region!.nameEn.isNotEmpty ? _region!.nameEn : _region!.code}' : 'Servers'),
            Text(
              _provider.displayName,
              style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: Column(
          children: [
            if (!_isLoading && _serverList.data.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search servers by name or OS...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
            Expanded(child: _buildBody(filtered)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<Server> servers) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(32),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.redAccent),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (servers.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(32),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.dns_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No servers match "$_searchQuery"'
                    : 'No Servers in Datacenter',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchData,
                icon: const Icon(Icons.refresh),
                label: const Text('Reload'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: servers.length,
      itemBuilder: (context, index) {
        final server = servers[index];
        final osName = server.image.os.toLowerCase();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF1F5F9),
              ),
              child: SvgPicture.asset(
                'assets/os/$osName.svg',
                width: 24,
                height: 24,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    server.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                StatusBadge.fromServerStatus(server.status),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'OS: ${server.image.os} ${server.image.osVersion} • ${server.flavor.vcpus} vCPU / ${server.flavor.ram} MB RAM',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              if (_region != null) {
                Navigator.pushNamed(
                  context,
                  '/servers/details',
                  arguments: ServerWithRegion(
                    server: server,
                    region: _region!,
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
