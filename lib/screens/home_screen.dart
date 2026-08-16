import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/region.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../widgets/status_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  final ApiService _apiService = ApiService();

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

    final apiKey = await _storageService.getApiKey();

    if (!mounted) return;

    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushNamed(context, '/settings');
      return;
    }

    try {
      final regionList = await _apiService.fetchRegions(apiKey);
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
        title: const Text('ArvanCloud Datacenters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
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
                    : 'No Datacenters Found',
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
                    region.nameEn,
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
                  Text('${region.cityEn} (${region.code.toUpperCase()})'),
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
