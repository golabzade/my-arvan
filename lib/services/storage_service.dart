import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _apiKeyKey = 'api_key';

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  Future<bool> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_apiKeyKey, apiKey.trim());
  }

  Future<bool> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_apiKeyKey);
  }
}
