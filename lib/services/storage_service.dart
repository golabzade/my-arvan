import 'package:shared_preferences/shared_preferences.dart';
import '../models/cloud_provider.dart';

class StorageService {
  static const String _legacyApiKeyKey = 'api_key';
  static const String _activeProviderKey = 'active_provider';

  String _getKeyForProvider(CloudProvider provider) {
    switch (provider) {
      case CloudProvider.arvanCloud:
        return 'arvan_api_key';
      case CloudProvider.ferdowsiCloud:
        return 'ferdowsi_api_key';
    }
  }

  Future<CloudProvider> getActiveProvider() async {
    final prefs = await SharedPreferences.getInstance();
    final providerId = prefs.getString(_activeProviderKey);
    return CloudProvider.fromId(providerId);
  }

  Future<bool> setActiveProvider(CloudProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_activeProviderKey, provider.id);
  }

  Future<String?> getApiKey([CloudProvider? provider]) async {
    final prefs = await SharedPreferences.getInstance();
    final targetProvider = provider ?? await getActiveProvider();
    final key = _getKeyForProvider(targetProvider);
    
    String? apiKey = prefs.getString(key);

    // Backward compatibility migration for legacy single api_key
    if ((apiKey == null || apiKey.isEmpty) && targetProvider == CloudProvider.arvanCloud) {
      final legacyKey = prefs.getString(_legacyApiKeyKey);
      if (legacyKey != null && legacyKey.isNotEmpty) {
        apiKey = legacyKey;
        await prefs.setString(key, legacyKey);
      }
    }

    return apiKey;
  }

  Future<bool> saveApiKey(CloudProvider provider, String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKeyForProvider(provider);
    return await prefs.setString(key, apiKey.trim());
  }

  Future<bool> clearApiKey(CloudProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getKeyForProvider(provider);
    if (provider == CloudProvider.arvanCloud) {
      await prefs.remove(_legacyApiKeyKey);
    }
    return await prefs.remove(key);
  }
}
