import 'region.dart';
import 'server.dart';

class ServerWithRegion {
  final Server server;
  final Region region;

  const ServerWithRegion({
    required this.server,
    required this.region,
  });
}