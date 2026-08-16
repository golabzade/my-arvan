import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_response.dart';
import '../models/region.dart';
import '../models/server.dart';
import 'api_service.dart';

class FerdowsiApiService {
  static const String _baseUrl = 'https://api.ferdowsi.cloud';

  Map<String, String> _buildHeaders(String apiKey) {
    return {
      'X-Api-Key': apiKey,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  dynamic _processResponse(http.Response response) {
    String decodedBody;
    try {
      decodedBody = utf8.decode(response.bodyBytes);
    } catch (_) {
      decodedBody = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decodedBody.trim().isEmpty) {
        return {};
      }
      try {
        return json.decode(decodedBody)['data'];
      } catch (_) {
        return {};
      }
    }

    String errorMessage = 'Ferdowsi API error (${response.statusCode})';
    try {
      final bodyJson = json.decode(decodedBody);
      dynamic errorObj = bodyJson;
      if (bodyJson is Map && bodyJson.containsKey('error')) {
        errorObj = bodyJson['error'];
      }
      if (errorObj is Map && errorObj.containsKey('detail') && errorObj['detail'] != null) {
        errorMessage = errorObj['detail'].toString();
      } else if (errorObj is Map && errorObj.containsKey('message') && errorObj['message'] != null) {
        errorMessage = errorObj['message'].toString();
      }
    } catch (_) {}

    throw ApiException(errorMessage, statusCode: response.statusCode);
  }

  Future<RegionList> fetchRegions(String apiKey) async {
    final uri = Uri.parse('$_baseUrl/api/v2/regions');
    try {
      final response = await http.get(uri, headers: _buildHeaders(apiKey));
      final jsonResult = _processResponse(response);
      if (jsonResult is List) {
        return RegionList.fromJson({'data': jsonResult});
      }
      return const RegionList(data: []);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to load Ferdowsi regions: $e');
    }
  }

  Future<ServerList> fetchServers(String apiKey, String regionCode) async {
    final uri = Uri.parse('$_baseUrl/api/v2/sm/$regionCode/virtual-machines');
    try {
      final response = await http.get(uri, headers: _buildHeaders(apiKey));
      final jsonResult = _processResponse(response);
      if (jsonResult is List) {
        return ServerList.fromJson({'data': jsonResult});
      }
      return const ServerList(data: []);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to load Ferdowsi virtual machines: $e');
    }
  }

  Future<Server> fetchServerDetails(
    String apiKey,
    String regionCode,
    String serverId,
  ) async {
    final uri = Uri.parse('$_baseUrl/api/v2/sm/$regionCode/virtual-machines/$serverId');
    try {
      final response = await http.get(uri, headers: _buildHeaders(apiKey));
      final jsonResult = _processResponse(response);
      if (jsonResult is List && jsonResult.isNotEmpty) {
        return Server.fromJson(jsonResult.first);
      } else if (jsonResult is Map<String, dynamic>) {
        return Server.fromJson(jsonResult);
      }
      throw ApiException('Invalid server response format from Ferdowsi Cloud');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to load Ferdowsi server details: $e');
    }
  }

  Future<MessageResponse> executeServerAction(
    String apiKey,
    String regionCode,
    String serverId,
    String action,
  ) async {
    // Map actions to Ferdowsi OpenAPI endpoints
    String bodyAction = action;
    if (action == 'power-on') bodyAction = 'start';
    if (action == 'power-off') bodyAction = 'stop';
    if (action == 'reboot') bodyAction = 'soft_reboot';
    if (action == 'hard-reboot') bodyAction = 'hard_reboot';

    final uri = Uri.parse('$_baseUrl/api/v2/sm/$regionCode/virtual-machines/$serverId/status');
    try {
      final response = await http.patch(uri, headers: _buildHeaders(apiKey), body: json.encode({'action': bodyAction}));
      _processResponse(response);
      return MessageResponse(
        message: 'Ferdowsi VM action "$action" requested successfully.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to execute action $action on Ferdowsi Cloud: $e');
    }
  }
}
