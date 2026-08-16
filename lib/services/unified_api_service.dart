import '../models/cloud_provider.dart';
import '../models/message_response.dart';
import '../models/region.dart';
import '../models/server.dart';
import 'api_service.dart';
import 'ferdowsi_api_service.dart';

class UnifiedApiService {
  final ApiService _arvanService = ApiService();
  final FerdowsiApiService _ferdowsiService = FerdowsiApiService();

  Future<RegionList> fetchRegions(CloudProvider provider, String apiKey) {
    switch (provider) {
      case CloudProvider.arvanCloud:
        return _arvanService.fetchRegions(apiKey);
      case CloudProvider.ferdowsiCloud:
        return _ferdowsiService.fetchRegions(apiKey);
    }
  }

  Future<ServerList> fetchServers(
    CloudProvider provider,
    String apiKey,
    String regionCode,
  ) {
    switch (provider) {
      case CloudProvider.arvanCloud:
        return _arvanService.fetchServers(apiKey, regionCode);
      case CloudProvider.ferdowsiCloud:
        return _ferdowsiService.fetchServers(apiKey, regionCode);
    }
  }

  Future<Server> fetchServerDetails(
    CloudProvider provider,
    String apiKey,
    String regionCode,
    String serverId,
  ) {
    switch (provider) {
      case CloudProvider.arvanCloud:
        return _arvanService.fetchServerDetails(apiKey, regionCode, serverId);
      case CloudProvider.ferdowsiCloud:
        return _ferdowsiService.fetchServerDetails(apiKey, regionCode, serverId);
    }
  }

  Future<MessageResponse> executeServerAction(
    CloudProvider provider,
    String apiKey,
    String regionCode,
    String serverId,
    String action,
  ) {
    switch (provider) {
      case CloudProvider.arvanCloud:
        return _arvanService.executeServerAction(
            apiKey, regionCode, serverId, action);
      case CloudProvider.ferdowsiCloud:
        return _ferdowsiService.executeServerAction(
            apiKey, regionCode, serverId, action);
    }
  }
}
