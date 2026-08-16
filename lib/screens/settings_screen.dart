import 'package:flutter/material.dart';
import '../models/cloud_provider.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/unified_api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  final UnifiedApiService _apiService = UnifiedApiService();

  final TextEditingController _arvanApiKeyController = TextEditingController();
  final TextEditingController _ferdowsiApiKeyController = TextEditingController();

  CloudProvider _activeProvider = CloudProvider.arvanCloud;
  bool _obscureArvan = true;
  bool _obscureFerdowsi = true;
  bool _isTestingArvan = false;
  bool _isTestingFerdowsi = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _arvanApiKeyController.dispose();
    _ferdowsiApiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final active = await _storageService.getActiveProvider();
    final arvanKey = await _storageService.getApiKey(CloudProvider.arvanCloud);
    final ferdowsiKey = await _storageService.getApiKey(CloudProvider.ferdowsiCloud);

    if (!mounted) return;

    setState(() {
      _activeProvider = active;
      if (arvanKey != null) _arvanApiKeyController.text = arvanKey;
      if (ferdowsiKey != null) _ferdowsiApiKeyController.text = ferdowsiKey;
    });
  }

  Future<void> _saveActiveProvider(CloudProvider provider) async {
    await _storageService.setActiveProvider(provider);
    if (!mounted) return;
    setState(() {
      _activeProvider = provider;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Active provider switched to ${provider.displayName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _saveApiKey(CloudProvider provider) async {
    final controller = provider == CloudProvider.arvanCloud
        ? _arvanApiKeyController
        : _ferdowsiApiKeyController;
    final apiKey = controller.text.trim();

    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid API Key for ${provider.displayName}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _storageService.saveApiKey(provider, apiKey);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${provider.displayName} API Key saved!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _testConnection(CloudProvider provider) async {
    final controller = provider == CloudProvider.arvanCloud
        ? _arvanApiKeyController
        : _ferdowsiApiKeyController;
    final apiKey = controller.text.trim();

    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter an API key for ${provider.displayName}'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      if (provider == CloudProvider.arvanCloud) {
        _isTestingArvan = true;
      } else {
        _isTestingFerdowsi = true;
      }
    });

    try {
      final regions = await _apiService.fetchRegions(provider, apiKey);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${provider.displayName} connection successful! (${regions.data.length} regions)'),
          backgroundColor: Colors.green,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          if (provider == CloudProvider.arvanCloud) {
            _isTestingArvan = false;
          } else {
            _isTestingFerdowsi = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActiveProviderCard(),
            const SizedBox(height: 16),
            _buildProviderConfigCard(
              provider: CloudProvider.arvanCloud,
              controller: _arvanApiKeyController,
              isObscure: _obscureArvan,
              isTesting: _isTestingArvan,
              onToggleObscure: () => setState(() => _obscureArvan = !_obscureArvan),
            ),
            const SizedBox(height: 16),
            _buildProviderConfigCard(
              provider: CloudProvider.ferdowsiCloud,
              controller: _ferdowsiApiKeyController,
              isObscure: _obscureFerdowsi,
              isTesting: _isTestingFerdowsi,
              onToggleObscure: () => setState(() => _obscureFerdowsi = !_obscureFerdowsi),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveProviderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Cloud Provider',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select which cloud platform to view datacenters and manage virtual machines.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SegmentedButton<CloudProvider>(
              segments: const [
                ButtonSegment(
                  value: CloudProvider.arvanCloud,
                  label: Text('ArvanCloud'),
                  icon: Icon(Icons.cloud_outlined),
                ),
                ButtonSegment(
                  value: CloudProvider.ferdowsiCloud,
                  label: Text('Ferdowsi Cloud'),
                  icon: Icon(Icons.cloud_queue),
                ),
              ],
              selected: {_activeProvider},
              onSelectionChanged: (newSelection) {
                _saveActiveProvider(newSelection.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderConfigCard({
    required CloudProvider provider,
    required TextEditingController controller,
    required bool isObscure,
    required bool isTesting,
    required VoidCallback onToggleObscure,
  }) {
    final isActive = _activeProvider == provider;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? const Color(0xFF0066FF) : const Color(0xFFE2E8F0),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  provider == CloudProvider.arvanCloud
                      ? Icons.cloud_outlined
                      : Icons.cloud_queue,
                  color: const Color(0xFF0066FF),
                ),
                const SizedBox(width: 8),
                Text(
                  '${provider.displayName} API Key',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isActive) ...[
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: isObscure,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: provider == CloudProvider.arvanCloud
                    ? 'Apikey xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
                    : 'x-api-key xxxxxxxx...',
                prefixIcon: const Icon(Icons.key),
                suffixIcon: IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: onToggleObscure,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _saveApiKey(provider),
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isTesting ? null : () => _testConnection(provider),
                    icon: isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_tethering, size: 18),
                    label: const Text('Test'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
