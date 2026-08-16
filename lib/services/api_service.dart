import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_response.dart';
import '../models/region.dart';
import '../models/server.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class ApiService {
  static const String _baseUrl = 'https://napi.arvancloud.ir';

  Map<String, String> _buildHeaders(String apiKey) {
    return {
      'Authorization': 'apikey $apiKey',
      'Accept': 'application/json',
    };
  }

  dynamic _processResponse(http.Response response) {
    String decodedBody;
    try {
      decodedBody = utf8.decode(response.bodyBytes);
    } catch (_) {
      decodedBody = response.body;
    }

    dynamic bodyJson;
    try {
      bodyJson = json.decode(decodedBody);
    } catch (_) {
      throw ApiException(
        'Server returned invalid response format (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return bodyJson;
    }

    String errorMessage = 'Request failed with status: ${response.statusCode}';
    if (bodyJson is Map && bodyJson.containsKey('message') && bodyJson['message'] != null) {
      errorMessage = bodyJson['message'].toString();
    }
    throw ApiException(errorMessage, statusCode: response.statusCode);
  }

  Future<RegionList> fetchRegions(String apiKey) async {
    final uri = Uri.parse('$_baseUrl/ecc/v2/datacenters');
    try {
      final response = await http.get(uri, headers: _buildHeaders(apiKey));
      final jsonResult = _processResponse(response);
      return RegionList.fromJson(jsonResult);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to load regions: $e');
    }
  }

  Future<ServerList> fetchServers(String apiKey, String regionCode) async {
    final uri = Uri.parse('$_baseUrl/ecc/v1/regions/$regionCode/servers');
    try {
      final response = await http.get(uri, headers: _buildHeaders(apiKey));
      final jsonResult = _processResponse(response);
      return ServerList.fromJson(jsonResult);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to load servers: $e');
    }
  }

  Future<Server> fetchServerDetails(String apiKey, String regionCode, String serverId) async {
    final uri = Uri.parse('$_baseUrl/ecc/v1/regions/$regionCode/servers/$serverId');
    try {
      final response = await http.get(uri, headers: _buildHeaders(apiKey));
      final jsonResult = _processResponse(response);
      if (jsonResult is Map<String, dynamic> && jsonResult.containsKey('data')) {
        return Server.fromJson(jsonResult['data']);
      }
      throw ApiException('Invalid server details response structure');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to load server details: $e');
    }
  }

  Future<MessageResponse> executeServerAction(
    String apiKey,
    String regionCode,
    String serverId,
    String action,
  ) async {
    final uri = Uri.parse('$_baseUrl/ecc/v1/regions/$regionCode/servers/$serverId/$action');
    try {
      final response = await http.post(uri, headers: _buildHeaders(apiKey));
      final jsonResult = _processResponse(response);
      return MessageResponse.fromJson(jsonResult);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to execute action $action: $e');
    }
  }
}
