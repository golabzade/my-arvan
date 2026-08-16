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

class ServerDetailsScreen extends StatefulWidget {
  const ServerDetailsScreen({super.key});

  @override
  State<ServerDetailsScreen> createState() => _ServerDetailsScreenState();
}

class _ServerDetailsScreenState extends State<ServerDetailsScreen> {
  final StorageService _storageService = StorageService();
  final UnifiedApiService _apiService = UnifiedApiService();

  Server? _server;
  Region? _region;
  CloudProvider _provider = CloudProvider.arvanCloud;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isActionExecuting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ServerWithRegion) {
        _server = args.server;
        _region = args.region;
        _fetchData();
      }
      _isInitialized = true;
    }
  }

  Future<void> _fetchData() async {
    if (_region == null || _server == null) return;

    setState(() {
      _isLoading = true;
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
      final updatedServer = await _apiService.fetchServerDetails(
        provider,
        apiKey,
        _region!.code,
        _server!.id,
      );
      if (!mounted) return;
      setState(() {
        _server = updatedServer;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.message),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to fetch server details: $e'),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmAndExecuteAction(
      String action, String title, String warningText) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm $title'),
        content: Text(warningText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  action == 'terminate' ? Colors.red : Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(title),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _callActionToServer(action);
    }
  }

  Future<void> _callActionToServer(String action) async {
    if (_region == null || _server == null) return;

    setState(() {
      _isActionExecuting = true;
    });

    final provider = await _storageService.getActiveProvider();
    final apiKey = await _storageService.getApiKey(provider);

    if (!mounted) return;

    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _isActionExecuting = false;
      });
      Navigator.pushNamed(context, '/settings');
      return;
    }

    try {
      final response = await _apiService.executeServerAction(
        provider,
        apiKey,
        _region!.code,
        _server!.id,
        action,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(response.message),
        ),
      );
      _fetchData();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.message),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to execute action: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isActionExecuting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_server != null ? _server!.name : 'Server Details'),
            Text(
              _provider.displayName,
              style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: _isLoading && _server == null
            ? const Center(child: CircularProgressIndicator())
            : _server == null
                ? const Center(child: Text('Server not found'))
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildServerHeaderCard(),
                        const SizedBox(height: 16),
                        _buildSpecificationsCard(),
                        const SizedBox(height: 16),
                        _buildIpAddressesCard(),
                        const SizedBox(height: 16),
                        _buildActionsCard(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildServerHeaderCard() {
    final osName = _server!.image.os.toLowerCase();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFF1F5F9),
              ),
              child: SvgPicture.asset(
                'assets/os/$osName.svg',
                width: 36,
                height: 36,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _server!.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StatusBadge.fromServerStatus(_server!.status),
                      const SizedBox(width: 8),
                      Text(
                        _region?.nameEn.isNotEmpty == true
                            ? _region!.nameEn
                            : (_region?.code ?? ''),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpecItem(
                    Icons.memory, 'vCPU', '${_server!.flavor.vcpus} Cores'),
                _buildSpecItem(
                    Icons.sd_card, 'RAM', '${_server!.flavor.ram} MB'),
                _buildSpecItem(
                    Icons.storage, 'Disk', '${_server!.flavor.disk} GB'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0066FF), size: 28),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildIpAddressesCard() {
    final addresses = _server!.addresses.data;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'IP Addresses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            if (addresses.isEmpty)
              const Text('No IP addresses assigned',
                  style: TextStyle(color: Colors.grey))
            else
              Column(
                children: addresses.map((addr) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'IPv${addr.version}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SelectableText(
                              addr.addr,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (addr.isPublic)
                          const Chip(
                            label: Text('Public', style: TextStyle(fontSize: 10)),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Power Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isActionExecuting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildActionButton(
                  label: 'Power On',
                  icon: Icons.power_settings_new,
                  color: Colors.green,
                  onPressed: _isActionExecuting
                      ? null
                      : () => _callActionToServer('power-on'),
                ),
                _buildActionButton(
                  label: 'Power Off',
                  icon: Icons.power_off,
                  color: Colors.orange,
                  onPressed: _isActionExecuting
                      ? null
                      : () => _confirmAndExecuteAction(
                            'power-off',
                            'Power Off',
                            'Are you sure you want to turn off server "${_server?.name}"?',
                          ),
                ),
                _buildActionButton(
                  label: 'Reboot',
                  icon: Icons.restart_alt,
                  color: Colors.blue,
                  onPressed: _isActionExecuting
                      ? null
                      : () => _confirmAndExecuteAction(
                            'reboot',
                            'Soft Reboot',
                            'Reboot server "${_server?.name}" cleanly?',
                          ),
                ),
                _buildActionButton(
                  label: 'Hard Reboot',
                  icon: Icons.refresh,
                  color: Colors.deepOrange,
                  onPressed: _isActionExecuting
                      ? null
                      : () => _confirmAndExecuteAction(
                            'hard-reboot',
                            'Hard Reboot',
                            'Force hard reboot on server "${_server?.name}"? Data might be lost if unsaved.',
                          ),
                ),
                if (_provider.supportsTerminate)
                  _buildActionButton(
                    label: 'Terminate',
                    icon: Icons.delete_forever,
                    color: Colors.red,
                    onPressed: _isActionExecuting
                        ? null
                        : () => _confirmAndExecuteAction(
                              'terminate',
                              'Terminate Server',
                              'WARNING: This will permanently delete server "${_server?.name}" and all attached volumes. This action CANNOT be undone.',
                            ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(25),
        foregroundColor: color,
        side: BorderSide(color: color.withAlpha(76)),
        elevation: 0,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
