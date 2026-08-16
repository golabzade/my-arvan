import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/cloud_provider.dart';
import '../models/region.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/unified_api_service.dart';
import '../widgets/status_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final UnifiedApiService _apiService = UnifiedApiService();

  CloudProvider _activeProvider = CloudProvider.arvanCloud;
  bool _isLoading = false;
  String? _errorMessage;
  RegionList _regionList = const RegionList(data: []);
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final provider = await _storageService.getActiveProvider();
    final apiKey = await _storageService.getApiKey(provider);

    if (!mounted) return;

    setState(() {
      _activeProvider = provider;
    });

    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushNamed(context, '/settings');
      return;
    }

    try {
      final regionList = await _apiService.fetchRegions(provider, apiKey);
      if (!mounted) return;
      setState(() {
        _regionList = regionList;
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
        _errorMessage = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _switchProvider(CloudProvider newProvider) async {
    if (newProvider == _activeProvider) return;
    await _storageService.setActiveProvider(newProvider);
    _fetchData();
  }

  List<Region> get _filteredRegions {
    if (_searchQuery.isEmpty) return _regionList.data;
    final query = _searchQuery.toLowerCase();
    return _regionList.data.where((region) {
      return region.nameEn.toLowerCase().contains(query) ||
          region.nameFa.contains(query) ||
          region.cityEn.toLowerCase().contains(query) ||
          region.code.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRegions;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datacenters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _activeProvider.displayName,
              style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<CloudProvider>(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch Cloud Provider',
            onSelected: _switchProvider,
            itemBuilder: (context) => CloudProvider.values.map((p) {
              return PopupMenuItem<CloudProvider>(
                value: p,
                child: Row(
                  children: [
                    Icon(
                      p == CloudProvider.arvanCloud
                          ? Icons.cloud_outlined
                          : Icons.cloud_queue,
                      color: p == _activeProvider ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      p.displayName,
                      style: TextStyle(
                        fontWeight: p == _activeProvider
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: p == _activeProvider ? Colors.blue : null,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              _fetchData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: Column(
          children: [
            if (!_isLoading && _regionList.data.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search datacenters...',
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
            Expanded(
              child: _buildBody(filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<Region> regions) {
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

    if (regions.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(32),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No datacenters match "$_searchQuery"'
                    : 'No Datacenters Found for ${_activeProvider.displayName}',
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
      itemCount: regions.length,
      itemBuilder: (context, index) {
        final region = regions[index];
        final name = region.nameEn.isNotEmpty ? region.nameEn : region.code;
        final city = region.cityEn.isNotEmpty ? region.cityEn : region.code;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: SizedBox(
              width: 44,
              height: 44,
              child: CircleAvatar(
                backgroundColor: const Color(0xFFF1F5F9),
                child: region.image.isNotEmpty
                    ? SvgPicture.network(
                        region.image,
                        width: 28,
                        height: 28,
                        placeholderBuilder: (_) => const Icon(Icons.dns, size: 24),
                      )
                    : const Icon(Icons.dns, size: 24, color: Color(0xFF0066FF)),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                StatusBadge.fromDatacenterState(region.state),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('$city (${region.code.toUpperCase()})'),
                ],
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => Navigator.pushNamed(
              context,
              '/servers',
              arguments: region,
            ),
          ),
        );
      },
    );
  }
}
